{ lib, config, ... }:

let
  cfg = config.qnix.system.boot-manager;
in
{
  config = lib.mkIf cfg.enable {
    boot = {
      supportedFilesystems = lib.mkIf cfg.zfsSupport {
        zfs = true;
      };

      loader = {
        timeout = cfg.timeout;

        efi = {
          efiSysMountPoint = "/boot";
          canTouchEfiVariables = true;
        };

        grub = lib.mkIf (cfg.loader == "grub") {
          enable = true;
          device = "nodev";
          efiSupport = true;
          zfsSupport = cfg.zfsSupport;
          enableCryptodisk = cfg.encrypted;
        };

        systemd-boot = lib.mkIf (cfg.loader == "systemd-boot") {
          enable = true;
          configurationLimit = 10;
          memtest86 = {
            enable = !config.qnix.status.vm;
            sortKey = "o_memtest86";
          };

          rebootForBitlocker = cfg.dualBoot;
        };
      };

      initrd = {
        systemd.enable = cfg.systemdSecondStage;
      };
    };
  };
}
