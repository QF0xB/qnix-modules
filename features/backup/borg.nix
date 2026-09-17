{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      repositories = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Named Borg repository URLs, such as ssh://user@host:port/./repo.";
      };

      sshKeyPath = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Path to the SSH private key used to access BorgBase.";
      };

      passphrasePaths = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Borg encryption passphrase paths keyed by repository name.";
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

    };

  nixos =
    {
      cfg,
      lib,
      ...
    }:
    {
      assertions = [
        {
          assertion = !cfg.enable || cfg.repositories != { };
          message = "qnix.backup.borg: at least one repository must be set when enabled.";
        }
        {
          assertion = !cfg.enable || cfg.sshKeyPath != "";
          message = "qnix.backup.borg: sshKeyPath must be set when enabled.";
        }
        {
          assertion = !cfg.enable || lib.attrNames cfg.passphrasePaths == lib.attrNames cfg.repositories;
          message = "qnix.backup.borg: passphrasePaths must contain one path per repository when enabled.";
        }
      ];

      services.borgbackup.jobs = lib.mkIf cfg.enable (
        lib.mapAttrs (name: repository: {
          repo = repository;
          paths = cfg.paths;
          startAt = cfg.schedule;
          doInit = true;
          compression = "zstd,6";
          extraCreateArgs = [ "--progress" ];
          encryption = {
            mode = "repokey-blake2";
            passCommand = "cat ${cfg.passphrasePaths.${name}}";
          };
          environment.BORG_RSH = "ssh -i ${cfg.sshKeyPath} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new";
        }) cfg.repositories
      );
    };
}
