{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  pkgs,
  ...
}:

let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.security.gpg;

  # Home Manager expects publicKeys to be a list of { source = path; } or { text = "key block"; }, with optional trust.
  toHMPublicKey =
    key:
    let
      withTrust =
        attrs: attrs // lib.optionalAttrs (key ? trust && key.trust != null) { trust = key.trust; };
    in
    if key ? url && key ? sha256 && key.url != null && key.sha256 != null then
      withTrust {
        source = "${pkgs.fetchurl {
          url = key.url;
          sha256 = key.sha256;
        }}";
      }
    else if key ? source && key.source != null then
      withTrust { source = key.source; }
    else if key ? text && key.text != null then
      withTrust { text = key.text; }
    else if lib.isPath key then
      { source = key; }
    else if lib.isString key then
      if lib.hasPrefix "-----BEGIN" key then { text = key; } else { source = key; }
    else
      throw "qnix.core.gpg.publicKeys: entry must be path, string, or attrset with url+sha256, source, or text (optional trust)";

  publicKeysForHM = map toHMPublicKey cfg.publicKeys;
in
{
  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = publicKeysForHM;
      settings = {
        use-agent = true;
        keyserver = "hkps://keys.openpgp.org";
      };

      scdaemonSettings = {
        disable-ccid = true;
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = cfg.enableSSH;
      enableExtraSocket = cfg.enableSSH;
      pinentry.package = cfg.pinentryPackage;

      # Cache TTLs
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      maxCacheTtl = 86400;
      maxCacheTtlSsh = 86400;
    };

    home.sessionVariables = lib.mkIf cfg.enableSSH {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
      GPG_TTY = "$(tty)";
    };

    # Ensure GPG agent socket directory exists and restart agent if needed
    home.activation.setupGpgSshSocket = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      runtime_dir="''${XDG_RUNTIME_DIR:-}"

      if [ -n "$runtime_dir" ] && [ ! -d "$runtime_dir/gnupg" ]; then
        mkdir -p "$runtime_dir/gnupg"
        chmod 700 "$runtime_dir/gnupg"
      fi

      # Ensure GPG agent is running (it will create the SSH socket)
      if [ -n "$runtime_dir" ] && [ -d "$runtime_dir" ]; then
        # Try to connect to agent, start if not running
        gpg-connect-agent /bye > /dev/null 2>&1 || true
      fi
    '';

    home.packages = [ pkgs.gnupg ];
  };
}
