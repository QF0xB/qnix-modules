{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "security.gpg" ];

  persistence.users."*".directories = [
    ".config/git"
    ".config/gh"
  ];

  options =
    { lib, ... }:
    {
      lfs = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether Git LFS is enabled.";
      };

      signing = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Git signs commits by default.";
      };

      signingKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional GPG key used for Git commit signing.";
      };

      userName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Git user name.";
      };

      userEmail = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Git user email address.";
      };

      aliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Git aliases.";
      };

      extraConfig = lib.mkOption {
        type = lib.types.attrs;
        default = {
          push.autoSetupRemote = true;
        };
        description = "Additional Git configuration.";
      };
    };

  nixos =
    { ... }:
    { };

  home =
    { cfg, lib, ... }:
    {
      programs.git = {
        enable = true;
        lfs.enable = cfg.lfs;
        settings =
          cfg.extraConfig
          // {
            user =
              { }
              // lib.optionalAttrs (cfg.userName != null) { name = cfg.userName; }
              // lib.optionalAttrs (cfg.userEmail != null) { email = cfg.userEmail; };
          }
          // lib.optionalAttrs (cfg.aliases != { }) { alias = cfg.aliases; };
        signing = {
          key = cfg.signingKey;
          signByDefault = cfg.signing;
        };
      };

      programs.gh.enable = true;
    };
}
