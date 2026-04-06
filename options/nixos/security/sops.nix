{ lib, ... }:
{
  options.qnix.security.sops = {
    enable = lib.mkEnableOption "sops";

    defaultSopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "The default sops file to use.";
    };

    age = {
      generateKey = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to generate an age key.";
      };

      keyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to the age key file used by sops.";
      };
    };

    secrets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              key = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };

              path = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };

              owner = lib.mkOption {
                type = lib.types.str;
                default = "root";
              };

              group = lib.mkOption {
                type = lib.types.str;
                default = "root";
              };

              mode = lib.mkOption {
                type = lib.types.str;
                default = "0400";
              };

              neededForUsers = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };

              restartUnits = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
            };
          }
        )
      );
      default = { };
    };
  };
}
