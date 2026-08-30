{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".gnupg" ];

  options =
    {
      lib,
      pkgs,
      ...
    }:
    let
      trustLevel = lib.types.enum [
        "unknown"
        "never"
        "marginal"
        "full"
        "ultimate"
        1
        2
        3
        4
        5
      ];

      publicKeyType = lib.types.oneOf [
        lib.types.path
        lib.types.str
        (lib.types.submodule {
          options = {
            url = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "URL to fetch the public key from.";
            };
            sha256 = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Hash of the public key fetched from url.";
            };
            source = lib.mkOption {
              type = lib.types.nullOr (lib.types.either lib.types.str lib.types.path);
              default = null;
              description = "Path or URL of a public key file.";
            };
            text = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Literal OpenPGP public key block.";
            };
            trust = lib.mkOption {
              type = lib.types.nullOr trustLevel;
              default = null;
              description = "Trust level assigned to the public key.";
            };
          };
        })
      ];
    in
    {
      enableSSH = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the GPG agent also provides an SSH agent.";
      };

      pinentryPackage = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = pkgs.pinentry-tty;
        description = "Package used by the GPG agent for pinentry.";
      };

      publicKeys = lib.mkOption {
        type = lib.types.listOf publicKeyType;
        default = [ ];
        description = "Public keys imported into the user's GPG keyring.";
      };
    };

  nixos =
    {
      cfg,
      ...
    }:
    {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = cfg.enableSSH;
        pinentryPackage = cfg.pinentryPackage;
      };
    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    let
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
          throw "qnix.security.gpg.publicKeys: entry must be a path, string, or attribute set with url+sha256, source, or text";
    in
    {
      programs.gpg = {
        enable = true;
        publicKeys = map toHMPublicKey cfg.publicKeys;
        settings = {
          use-agent = true;
          keyserver = "hkps://keys.openpgp.org";
        };
        scdaemonSettings.disable-ccid = true;
      };

      services.gpg-agent = {
        enable = true;
        enableSshSupport = cfg.enableSSH;
        enableExtraSocket = cfg.enableSSH;
        pinentry.package = cfg.pinentryPackage;
        defaultCacheTtl = 3600;
        defaultCacheTtlSsh = 3600;
        maxCacheTtl = 86400;
        maxCacheTtlSsh = 86400;
      };

      home.sessionVariables = lib.mkIf cfg.enableSSH {
        SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
        GPG_TTY = "$(tty)";
      };

      home.packages = [ pkgs.gnupg ];
    };
}
