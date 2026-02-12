{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.core.gpg;
  yubikeyEnabled = osConfig.qnix.core.yubikey.enable or false;

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
    # GPG configuration
    programs.gpg = {
      enable = true;
      publicKeys = publicKeysForHM;
      settings = {
        # Use agent for pinentry
        use-agent = true;
        # Default key server
        keyserver = "hkps://keys.openpgp.org";
      };
    };

    # Configure GPG agent
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

    # Set up environment variables for SSH agent
    # The socket path is created by gpg-agent when enableSSHSupport is true
    home.sessionVariables = lib.mkIf cfg.enableSSH {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
      GPG_TTY = "$(tty)";
    };

    # Ensure GPG agent socket directory exists and restart agent if needed
    home.activation.setupGpgSshSocket = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "$XDG_RUNTIME_DIR/gnupg" ]; then
        mkdir -p "$XDG_RUNTIME_DIR/gnupg"
        chmod 700 "$XDG_RUNTIME_DIR/gnupg"
      fi

      # Ensure GPG agent is running (it will create the SSH socket)
      if [ "$XDG_RUNTIME_DIR" != "" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
        # Try to connect to agent, start if not running
        gpg-connect-agent /bye > /dev/null 2>&1 || true
      fi
    '';

    home.packages = lib.mkIf yubikeyEnabled [
      pkgs.gnupg
    ];
  };
}
