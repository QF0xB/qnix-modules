{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      loader = lib.mkOption {
        type = lib.types.enum [
          "systemd-boot"
          "grub"
        ];
        default = "systemd-boot";
        description = "Boot loader used by the system.";
      };

      timeout = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Boot loader menu timeout in seconds.";
      };

      zfsSupport = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the boot configuration supports ZFS.";
      };

      encrypted = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether GRUB should support encrypted boot disks.";
      };

      systemdSecondStage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable systemd in the initrd.";
      };

      dualBoot = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the boot loader should support dual-boot behavior.";
      };

      configurationLimit = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "Maximum number of generations kept by systemd-boot.";
      };
    };

  nixos =
    { cfg, lib, ... }:
    {
      boot = {
        supportedFilesystems = lib.mkIf cfg.zfsSupport { zfs = true; };

        loader = {
          timeout = cfg.timeout;
          efi = {
            efiSysMountPoint = "/boot";
            canTouchEfiVariables = true;
          };

          systemd-boot = lib.mkIf (cfg.loader == "systemd-boot") {
            enable = true;
            configurationLimit = cfg.configurationLimit;
            rebootForBitlocker = cfg.dualBoot;
          };

          grub = lib.mkIf (cfg.loader == "grub") {
            enable = true;
            device = "nodev";
            efiSupport = true;
            zfsSupport = cfg.zfsSupport;
            enableCryptodisk = cfg.encrypted;
          };
        };

        initrd.systemd.enable = cfg.systemdSecondStage;
      };
    };
}
