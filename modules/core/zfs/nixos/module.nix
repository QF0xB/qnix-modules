{ lib, config, pkgs, ... }:

let
  cfg = config.hm.qnix.core.zfs;
in
{
  config = lib.mkIf cfg.enable {
    services.zfs = {
      autoScrub.enable = cfg.scrub.enable;
      autoScrub.interval = "${cfg.scrub.interval}h";
      trim.enable = true;
    };

    boot.initrd.systemd.services.postResume = lib.mkIf config.qnix.core.impermanence.enable {
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
      script = ''
        # Your commands here
        zfs list -t snapshot
        echo "Rollback zroot"
        zfs rollback -r zroot/root@blank
      '';
    };  
  };
}
