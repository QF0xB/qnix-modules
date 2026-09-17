{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      role = lib.mkOption {
        type = lib.types.enum [
          "client"
          "manager"
        ];
        default = "client";
        description = "Whether this machine creates backups or manages an append-only repository.";
      };

      repositories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Borg repository URLs, such as ssh://user@host:port/./repo.";
      };

      sshKeyPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Path to the SSH private key used to access BorgBase.";
      };

      passphrasePath = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Path to the Borg encryption passphrase.";
      };

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/persist" ];
        description = "Paths backed up by a client. Managers do not create archives.";
      };

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "systemd calendar expression for the Borg job.";
      };

      retention = {
        daily = lib.mkOption {
          type = lib.types.int;
          default = 7;
          description = "Daily archives retained by a manager.";
        };
        weekly = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Weekly archives retained by a manager.";
        };
        monthly = lib.mkOption {
          type = lib.types.int;
          default = 12;
          description = "Monthly archives retained by a manager.";
        };
      };
    };

  nixos =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    let
      job = pkgs.writeShellApplication {
        name = "qnix-borg-${cfg.role}";
        runtimeInputs = [
          pkgs.borgbackup
          pkgs.coreutils
          pkgs.openssh
        ];
        text = ''
          set -euo pipefail

          export BORG_PASSCOMMAND=${lib.escapeShellArg "cat ${cfg.passphrasePath}"}
          export BORG_RSH=${lib.escapeShellArg "ssh -i ${cfg.sshKeyPath} -o IdentitiesOnly=yes"}
          repositories=(${lib.escapeShellArgs cfg.repositories})

          for repository in "''${repositories[@]}"; do
            export BORG_REPO="$repository"
            ${
              if cfg.role == "client" then
                ''
                  borg create --stats --compression zstd,6 \
                    "::{hostname}-{now}" \
                    ${lib.escapeShellArgs cfg.paths}
                ''
              else
                ''
                  borg prune --list --glob-archives "{hostname}-*" \
                    --keep-daily ${toString cfg.retention.daily} \
                    --keep-weekly ${toString cfg.retention.weekly} \
                    --keep-monthly ${toString cfg.retention.monthly}
                  borg compact
                  borg check --repository-only
                ''
            }
          done
        '';
      };
    in
    {
      assertions = [
        {
          assertion = !cfg.enable || cfg.repositories != [ ];
          message = "qnix.backup.borg: at least one repository must be set when enabled.";
        }
        {
          assertion = !cfg.enable || cfg.sshKeyPath != "";
          message = "qnix.backup.borg: sshKeyPath must be set when enabled.";
        }
        {
          assertion = !cfg.enable || cfg.passphrasePath != "";
          message = "qnix.backup.borg: passphrasePath must be set when enabled.";
        }
      ];

      systemd.services.qnix-borg = lib.mkIf cfg.enable {
        description = "QNix Borg ${cfg.role}";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${job}/bin/qnix-borg-${cfg.role}";
          Nice = 19;
          IOSchedulingClass = "idle";
        };
      };

      systemd.timers.qnix-borg = lib.mkIf cfg.enable {
        description = "Run QNix Borg ${cfg.role}";
        wantedBy = [ "timers.target" ];
        timer = {
          OnCalendar = cfg.schedule;
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
}
