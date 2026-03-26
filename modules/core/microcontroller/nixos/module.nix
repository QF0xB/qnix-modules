{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.core.microcontroller;
in
{
  config = lib.mkIf cfg.enable {
    services.udev.packages = with pkgs; [
      openocd
      stlink
    ];

    environment.systemPackages = with pkgs; [
      openocd
      stlink
      stm32cubemx
    ];

    qnix.core.user.defaultExtraGroups = [ "dialout" ];
  };
}
