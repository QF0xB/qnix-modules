{ lib, ... }:
{
  options.qnix.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland";

    noHardwareCursors = lib.mkEnableOption "disable hardware cursors";
  };
}
