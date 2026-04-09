{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.desktop.wayland;
in
{
  config = lib.mkIf cfg.enable {
    xdg.portal = lib.mkIf cfg.portal.enable {
      enable = true;
      xdgOpenUsePortal = cfg.portal.xdgOpenUsePortal;
      extraPortals = [ cfg.portal.package ] ++ cfg.portal.extraPackages;
    };
  };
}
