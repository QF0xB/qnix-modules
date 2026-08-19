{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      defaultSopsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Default encrypted file used by sops-nix.";
      };

      validateSopsFiles = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether sops-nix should validate encrypted files during evaluation.";
      };

      age = {
        generateKey = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether sops-nix should generate an age key.";
        };

        keyFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Age key file used by sops-nix.";
        };
      };

      secrets = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
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
        );
        default = { };
        description = "Secrets managed by sops-nix.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      ...
    }:
    {
      sops = {
        validateSopsFiles = cfg.validateSopsFiles;
        age = {
          generateKey = cfg.age.generateKey;
          keyFile = cfg.age.keyFile;
        };
        secrets = lib.mapAttrs (
          _name: secretCfg:
          lib.filterAttrs (_: value: value != null) {
            key = secretCfg.key;
            path = secretCfg.path;
            owner = secretCfg.owner;
            group = secretCfg.group;
            mode = secretCfg.mode;
            neededForUsers = secretCfg.neededForUsers;
            restartUnits = secretCfg.restartUnits;
          }
        ) cfg.secrets;
      }
      // lib.optionalAttrs (cfg.defaultSopsFile != null) {
        defaultSopsFile = cfg.defaultSopsFile;
      };
    };
}
