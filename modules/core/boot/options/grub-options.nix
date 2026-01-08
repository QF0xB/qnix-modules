{ lib, ... }:

{
  options.qnix.core.boot.grub = with lib; {
    enable = mkEnableOption "grub bootloader" // {
      default = false;
    };

    device = mkOption {
      type = types.str;
      default = "nodev";
      description = "Device to use for GRUB";
    };
  };
}