{ lib, ... }:
{
  options.qnix.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland";

    noHardwareCursors = lib.mkEnableOption "disable hardware cursors";

    setDefaultKeybinds = lib.mkEnableOption "default Hyprland keybinds" // {
      default = true;
    };

    setDefaultWindowRules = lib.mkEnableOption "default Hyprland window rules" // {
      default = true;
    };

    setDefaultSpecialWorkspace = lib.mkEnableOption "default special workspace behavior" // {
      default = true;
    };
  };
}
