{ lib, ... }:
{
  options.qnix.system.boot-manager = {
    enable = lib.mkEnableOption "boot manager";

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
}
