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
      workspace_rule = [
        {
          workspace = "s[true]";
          gaps_out = 80;
          gaps_in = 20;
        }
      ];

      animation = [
        {
          leaf = "specialWorkspace";
          enabled = performanceMode;
          speed = 8;
          bezier = "default";
          style = "slidevert";
        }
      ];
    };
  };
}
