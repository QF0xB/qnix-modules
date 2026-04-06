{ lib, config, ... }:

let
  cfg = config.qnix.system.boot-manager;
in
{
  options = {
    qnix.system.boot-manager = {
      loader = lib.mkOption {
        type = lib.types.enum [
          "systemd-boot"
          "grub"
        ];
        default = "systemd-boot";
        description = "The loader to use for the boot manager";
      };

      encrypted = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to encrypt the boot partition";
      };

      timeout = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "The timeout in seconds for the boot manager";
      };

      zfsSupport = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to support ZFS";
      };

      systemdSecondStage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to support systemd second stage";
      };

      dualBoot = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to support dual boot";
      };
    };
  };

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
          storeConfig = true;
          memtest86 = { 
            enable = !config.qnix.status.vm;
            sortKey = "o_memtest86";
          };

          rebootForBitlocker = cfg.dualBoot;
        };
      };

      initrd = {
        systemd.enable = cfg.systemdSecondStage;
      }
    };
  };
}
