{
  lib,
  config ? null,
  ...
}:

{
  imports = [
    ./grub-options.nix
    ./systemd-boot-options.nix
  ];

  options.qnix.core.boot = {
    encrypted = lib.mkEnableOption "encrypted boot" // {
      default = if config != null then !config.qnix.server else true;
    };

    timeout = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Timeout for Boot";
    };

    encryptedDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/disk/by-label/NIXBOOT";
      description = "Device to use for encrypted boot";
    };

    zfsSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ZFS support";
    };

    efiSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable EFI support";
    };
  };
}
