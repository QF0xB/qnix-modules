{ lib, ... }:
{
  options.qnix.system.users = {
    enable = lib.mkEnableOption "users";

    defaultExtraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Groups added to all managed normal users.";
    };

    root = {
      enable = lib.mkEnableOption "root user management";

      initialHashedPassword = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Initial hashed password for root.";
      };

      passwordFromSops = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "SOPS secret name containing the root hashed password.";
      };
    };

    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            kind = lib.mkOption {
              type = lib.types.enum [
                "normal"
                "system"
              ];
              default = "normal";
            };

            group = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            home = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            description = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            extraGroups = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            initialHashedPassword = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            passwordFromSops = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            openssh.authorizedKeys.keys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            ignoreShellProgramCheck = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
          };
        }
      );
      default = { };
    };
  };
}
