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

    # withUWSM provides a dedicated display-manager session. Selecting the raw
    # "hyprland" session bypasses UWSM and therefore its systemd session setup.
    services.displayManager.defaultSession = lib.mkDefault "hyprland-uwsm";

    # Use the upstream user unit and attach it to the graphical session instead
    # of starting systemctl from Hyprland's configuration.
    systemd.user.packages = [ pkgs.hyprpolkitagent ];
    systemd.user.targets.graphical-session.wants = [ "hyprpolkitagent.service" ];

    qnix.persist.users."*".files = [
      ".config/hypr/monitors.conf"
      ".config/hypr/workspaces.conf"
    ];
  };
}
