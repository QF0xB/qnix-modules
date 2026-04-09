{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    services.displayManager.defaultSession = lib.mkDefault "hyprland";

    environment.systemPackages = [ pkgs.hyprpolkitagent ];

    qnix.persist.users."*".files = [
      ".config/hypr/monitors.conf"
      ".config/hypr/workspaces.conf"
    ];
  };
}
