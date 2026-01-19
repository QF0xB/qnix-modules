{ lib, config, ... }:

{
  options.qnix.desktop.hyprdesktop.hyprsuite.hyprland = {
    enable = lib.mkEnableOption "hyprland" // {
      default = config.qnix.desktop.hyprdesktop.enable;
    };
  };
}
