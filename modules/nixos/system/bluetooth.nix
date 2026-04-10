{ lib, config, ... }:
let
  cfg = config.qnix.system.bluetooth;
in
{
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.powerOnBoot;
    };

    services.blueman.enable = cfg.manager.enable;

    qnix.persist.root.directories = [
      "/var/lib/bluetooth"
    ];
  };
}
