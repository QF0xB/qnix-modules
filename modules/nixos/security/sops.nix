{
  lib,
  config,
  options,
  ...
}:

let
  cfg = config.qnix.security.sops;
in
{
  options = {
    qnix.security.sops = {
      enable = lib.mkEnableOption "sops-nix integration";

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
  };

  config = lib.mkIf (cfg.enable && options ? sops) {
    sops = {
      defaultSopsFile = cfg.defaultSopsFile;

      age = {
        generateKey = cfg.age.generateKey;
        keyFile = cfg.age.keyFile;
      };

      secrets = lib.mapAttrs (_name: secretCfg: {
        key = secretCfg.key;
        path = secretCfg.path;
        owner = secretCfg.owner;
        group = secretCfg.group;
        mode = secretCfg.mode;
        neededForUsers = secretCfg.neededForUsers;
        restartUnits = secretCfg.restartUnits;
      }) cfg.secrets;
    };
  };
}
