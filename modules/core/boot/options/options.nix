{ lib, ... }:

{
  options.qnix.core.boot = {
    grub.enable = lib.mkEnableOption "grub bootloader" // {
      default = false;
    };
  };
}
