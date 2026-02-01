{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.desktop.displaymanager.sddm;
  displaymanagerCfg = config.qnix.desktop.displaymanager;
in
{
  config = lib.mkIf (displaymanagerCfg.enable && cfg.enable) {
    environment.systemPackages =
      with pkgs;
      [
        kdePackages.qtmultimedia
      ]
      ++ lib.optional (cfg.theme.package != null) (
        cfg.theme.package.override { embeddedTheme = cfg.theme.embeddedTheme; }
      );

    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      theme = cfg.theme.name;
    };
  };
}
