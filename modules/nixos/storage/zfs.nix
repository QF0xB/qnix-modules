{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.storage.zfs;
in
{
  options = {
    qnix = {
      storage.zfs = {
        scrub = {
          enable = lib.mkEnableOption "zfs scrub" // {
            default = true;
          };

          interval = lib.mkOption {
            type = lib.types.str;
            default = "daily";
            description = "The interval at which to scrub the ZFS pool.";
          };
        };

        trim = {
          enable = lib.mkEnableOption "zfs trim" // {
            default = true;
          };

          interval = lib.mkOption {
            type = lib.types.str;
            default = "daily";
            description = "The interval at which to trim the ZFS pool.";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.zfs = {
      autoScrub.enable = cfg.scrub.enable;
      autoScrub.interval = cfg.scrub.interval;
      trim.enable = cfg.trim.enable;
      trim.interval = cfg.trim.interval;
    };

    boot.initrd.systemd.services.postResume = lib.mkIf config.qnix.storage.impermanence.enable {
      description = "Run commands after decrypt";
      wantedBy = [ "initrd.target" ];
      after = [
        "systemd-cryptsetup@cryptroot.service"
        "zfs-import.target"
      ];
      before = [ "sysroot.mount" ];

      path = with pkgs; [ zfs ]; # Add any necessary packages here
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.StandardOutput = "journal+console";
      serviceConfig.StandardError = "journal+console";
      script = ''
        echo "postResume service started at $(date)"
        echo "Listing snapshots before rollback:"
        zfs list -t snapshot zroot/root || true
        echo "Rollback zroot/root@blank"
        zfs rollback -r zroot/root@blank
        echo "postResume service completed at $(date)"
      '';
    };
  };
}
