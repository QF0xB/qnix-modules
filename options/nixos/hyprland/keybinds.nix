{ lib, ... }:
{
  options.qnix.desktop.hyprland.keybinds.enable = lib.mkEnableOption "Hyprland keybinds" // {
    default = true;
  };
}
