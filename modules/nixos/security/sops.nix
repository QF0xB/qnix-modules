{ lib, config, ... }:

let
  cfg = config.qnix.security.sops;
in
{
  imports = lib.optional (inputs ? sops-nix) inputs.sops-nix.nixosModules.sops;

  options = {
    qnix.security.sops = {
      defaultSecretFile = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = "The default secret file to use for sops";
      };

      age = {
        keyFile = lib.mkOption {
          type = lib.types.str;
          default = null;
          description = "The age key file to use for sops";
        };

        keyType = lib.mkOption {
          type = lib.types.str;
          default = "rsa";
          description = "The age key type to use for sops";
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

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = lib.mkIf (cfg.defaultSopsFile != null) cfg.defaultSopsFile;

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
