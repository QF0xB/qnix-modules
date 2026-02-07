{
  osConfig,
  lib,
  isVm,
  ...
}:

let
  cfg = osConfig.qnix.desktop.hyprdesktop;
  vm-performance = if isVm then false else true;
in
lib.mkIf (cfg.enable && cfg.hyprsuite.hyprland.setDefaultSpecialWorkspace) {
  wayland.windowManager.hyprland.settings = {
    # Special workspace gaps
    workspace = [ "s[true], gapsout:80, gapsin:20" ];

    decoration = {
      dim_special = "0.7";
      blur.special = vm-performance;
    };

    animations = {
      enabled = vm-performance;
      workspace_wraparound = true;
      animation = [ "specialWorkspace, 1, 8, default, slidevert" ];
    };
  };
}
