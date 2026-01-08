{ lib, ... }:

{
  options.qnix.core.boot.systemd-boot = with lib; {
    enable = mkEnableOption "systemd-boot bootloader" // {
      default = false;
    };
  };
}

