{ lib, config, ... }:

{
  options.qnix.desktop.hyprdesktop.hyprsuite.hyprland = {
    enable = lib.mkEnableOption "hyprland" // {
      default = config.qnix.desktop.hyprdesktop.enable;
    };

    setDefaultKeybinds = lib.mkEnableOption "set default keybinds" // {
      default = true;
    };

    setDefaultWindowRules = lib.mkEnableOption "set default window rules" // {
      default = true;
    };

    setDefaultAnimations = lib.mkEnableOption "set default animations" // {
      default = true;
    };

    setDefaultSpecialWorkspace = lib.mkEnableOption "set default special workspace settings" // {
      default = true;
    };
  };
}
