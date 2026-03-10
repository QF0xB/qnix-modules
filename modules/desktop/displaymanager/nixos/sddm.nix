{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.desktop.displaymanager.sddm;
  displaymanagerCfg = config.qnix.desktop.displaymanager;
  themePackage = if cfg.theme.package != null then cfg.theme.package else pkgs.sddm-astronaut;
in
{
  config = lib.mkIf (displaymanagerCfg.enable && cfg.enable) {
    environment.systemPackages =
      with pkgs;
      [
        kdePackages.qtmultimedia
      ]
      ++ lib.optional (themePackage != null) (
        themePackage.override { embeddedTheme = cfg.theme.embeddedTheme; }
      );

    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      theme = cfg.theme.name;
    };
  };
}
