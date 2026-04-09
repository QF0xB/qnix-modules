{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.desktop.wayland;
in
{
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
