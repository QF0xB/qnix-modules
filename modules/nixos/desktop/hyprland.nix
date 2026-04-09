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

    environment.systemPackages = [ pkgs.hyprpolkitagent ];
  };
}
