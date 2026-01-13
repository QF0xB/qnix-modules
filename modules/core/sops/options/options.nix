{ lib, ... }:

{
  options.qnix.core.sops = {
    enable = lib.mkEnableOption "sops" // {
      default = false;
    };

    defaultSopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Default Sops File to decrypt and use. Can be overridden per-secret with sopsFile.";
    };

    age = {
      generateKey = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to generate an age key automatically.";
      };

      keyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to the age key file. Defaults to /persist/home/<user>/.config/age/keys.txt if user is available.";
      };
    };

    secrets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            sopsFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Path to the sops file containing this secret. Defaults to defaultSopsFile.";
            };

            key = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Key name in the sops file. Defaults to the secret name.";
            };

            owner = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Owner of the decrypted secret file.";
            };

            group = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Group of the decrypted secret file.";
            };

            mode = lib.mkOption {
              type = lib.types.str;
              default = "0400";
              description = "File mode (permissions) for the decrypted secret file.";
            };

            path = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Path where the decrypted secret will be placed. Defaults to /run/secrets/<name>.";
            };

            restartUnits = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of systemd units to restart when this secret changes.";
            };

            reloadUnits = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of systemd units to reload when this secret changes.";
            };

            format = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum [
                  "binary"
                  "yaml"
                ]
              );
              default = null;
              description = "Format of the secret. 'binary' for raw bytes, 'yaml' for YAML parsing.";
            };

            neededBy = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of systemd units that need this secret.";
            };

            wantedBy = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of systemd units that want this secret.";
            };
          };
        }
      );
      default = { };
      description = "Secrets to decrypt and provision. Each secret maps to sops.secrets.*";
    };
  };
}
