{ lib, ... }:
{
  options.qnix.desktop.hyprland.rules.enable = lib.mkEnableOption "Hyprland window rules" // {
    default = true;
  };
}
