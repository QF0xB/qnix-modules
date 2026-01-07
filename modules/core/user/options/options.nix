{ lib, ... }:

{
  options.qnix.core.user = {
    enable = lib.mkEnableOption "user" // {
      default = false;
    };

    root = {
      enable = lib.mkEnableOption "root user" // {
        default = false;
      };
      password = lib.mkOption {
        type = lib.types.str;
        description = "The password for the root user";
        default = "";
      };
    };

    defaultExtraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Groups to add to all users by default (e.g., [ \"video\" \"audio\" ])";
      example = [ "video" "audio" ];
    };

    # Users as an attribute set: username -> user config
    # Only the attributes defined in the submodule are allowed
    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          isNormalUser = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether this is a normal user (exactly one of isNormalUser or isSystemUser must be set)";
          };
          isSystemUser = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this is a system user (exactly one of isNormalUser or isSystemUser must be set)";
          };
          group = lib.mkOption {
            type = lib.types.str;
            description = "Primary group for the user (required)";
          };
          home = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Home directory path";
          };
          description = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "User description/comment";
          };
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Additional groups for the user";
          };
          initialHashedPassword = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Initial hashed password";
          };
          openssh.authorizedKeys.keys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "SSH authorized keys";
          };
          ignoreShellProgramCheck = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Ignore shell program check";
          };
        };
      });
      default = {};
      description = "Users to create (attrset: username -> user config)";
    };
  };
}
