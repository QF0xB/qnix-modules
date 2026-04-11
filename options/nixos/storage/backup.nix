{ lib, ... }:
let
  scheduleType = lib.types.either lib.types.str (lib.types.listOf lib.types.str);
  pruneKeepType = lib.types.attrsOf (lib.types.either lib.types.int lib.types.str);
  encryptionModeType = lib.types.enum [
    "repokey"
    "keyfile"
    "repokey-blake2"
    "keyfile-blake2"
    "authenticated"
    "authenticated-blake2"
    "none"
  ];

  targetType =
    { name, withNfsMount ? false, withSshKey ? true }:
    lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "${name} backup target";

        repo = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Borg repository URL or local path for the ${name} backup target.";
        };

        startAt = lib.mkOption {
          type = lib.types.nullOr scheduleType;
          default = null;
          description = "Optional schedule override for the ${name} backup target.";
        };

        doInit = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to initialize the ${name} repository automatically if it does not exist.";
        };

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Extra environment variables for the ${name} Borg job.";
        };

        readWritePaths = lib.mkOption {
          type = lib.types.listOf lib.types.path;
          default = [ ];
          description = "Additional writable paths for the ${name} Borg job.";
        };

        preHook = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Shell commands to run before the ${name} backup starts.";
        };

        extraCreateArgs = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Additional arguments passed to `borg create` for the ${name} target.";
        };

        prune.keep = lib.mkOption {
          type = pruneKeepType;
          default = { };
          description = "Optional prune retention overrides for the ${name} target.";
        };

        encryption = {
          mode = lib.mkOption {
            type = encryptionModeType;
            default = "repokey-blake2";
            description = "Borg encryption mode for the ${name} target.";
          };

          passCommand = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Command that prints the Borg passphrase for the ${name} target.";
          };

          sopsSecretName = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "If set, derive the ${name} passphrase command from `sops.secrets.<name>.path`.";
          };
        };
      }
      // lib.optionalAttrs withSshKey {
        sshKeyPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "SSH private key path to use for the ${name} Borg target.";
        };

        sshKnownHostsFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Known hosts file to use for SSH host key verification for the ${name} Borg target.";
        };
      }
      // lib.optionalAttrs withNfsMount {
        mount = {
          enable = lib.mkEnableOption "NFS mount for the ${name} backup target" // {
            default = true;
          };

          what = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "NFS export to mount for the ${name} target, for example `nas:/srv/backup`.";
          };

          where = lib.mkOption {
            type = lib.types.str;
            default = "/mnt/backup-nfs";
            description = "Local mount point for the ${name} NFS export.";
          };

          options = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "nofail"
              "_netdev"
              "x-systemd.automount"
              "noatime"
            ];
            description = "Mount options for the ${name} NFS export.";
          };
        };
      };
    };
in
{
  options.qnix.storage.backup = {
    enable = lib.mkEnableOption "backup jobs";

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/persist"
      ];
      description = "Paths to include in all backup jobs.";
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/nix"
        "/tmp"
        "/var/tmp"
        "/var/cache"
        "/home/*/.cache"
        "/home/*/.local/share/Trash"
      ];
      description = "Borg exclusion patterns applied to all backup jobs.";
    };

    compression = lib.mkOption {
      type = lib.types.str;
      default = "zstd,6";
      description = "Compression method used for all backup jobs.";
    };

    extraCreateArgs = lib.mkOption {
      type = lib.types.lines;
      default = ''
        --stats
        --list
      '';
      description = "Default arguments passed to `borg create` for all backup jobs.";
    };

    startAt = lib.mkOption {
      type = scheduleType;
      default = "daily";
      description = "Default backup schedule for jobs that do not override it.";
    };

    persistentTimer = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run missed backups on next boot.";
    };

    inhibitsSleep = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Prevent sleeping while backups are running.";
    };

    prune.keep = lib.mkOption {
      type = pruneKeepType;
      default = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
      description = "Default Borg prune retention settings.";
    };

    targets = {
      borg = lib.mkOption {
        type = lib.types.attrsOf (
          targetType {
            name = "Borg";
          }
        );
        default = { };
        description = "Named Borg backup targets, for example multiple BorgBase repositories.";
      };

      nfs = lib.mkOption {
        type = lib.types.attrsOf (
          targetType {
            name = "NFS";
            withNfsMount = true;
            withSshKey = false;
          }
        );
        default = { };
        description = "Named Borg targets backed by local repositories stored on NFS mounts.";
      };
    };
  };
}
