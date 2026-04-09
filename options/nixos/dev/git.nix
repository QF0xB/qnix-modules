{ lib, ... }:
{
  options.qnix.dev.git = {
    enable = lib.mkEnableOption "git";

    lfs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether Git LFS should be enabled.";
    };

    signing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether commits should be signed by default.";
    };

    signingKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional GPG signing key for Git.";
    };

    userName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Git user name.";
    };

    userEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Git user email.";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Git aliases to configure.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional Git configuration merged into programs.git.extraConfig.";
    };
  };
}
