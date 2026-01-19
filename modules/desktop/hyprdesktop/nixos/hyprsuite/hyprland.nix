{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.qnix.desktop.hyprdesktop;
in
{
  config = lib.mkIf (cfg.enable && cfg.hyprsuite.hyprland.enable) {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    qnix.persist.home.files = [
      ".config/hypr/monitors.conf"
      ".config/hypr/workspaces.conf"
    ];
  };
}
