{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  hyprCfg = qconfig.desktop.hyprland or { enable = false; };
  cfg = hyprCfg.specialWorkspaces or { enable = true; };
  isVm = qconfig.status.vm or false;
  performanceMode = !isVm;
in
{
  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    wayland.windowManager.hyprland.settings = {
      workspace = [ "s[true], gapsout:80, gapsin:20" ];

      decoration = {
        dim_special = 0.7;
        blur.special = performanceMode;
      };

      animations = {
        enabled = performanceMode;
        workspace_wraparound = false;
        animation = [ "specialWorkspace, 1, 8, default, slidevert" ];
      };
    };
  };
}
