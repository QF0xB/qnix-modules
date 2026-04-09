{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.desktop.displaymanager;
  sddmCfg = cfg.sddm;
  themePackage =
    if sddmCfg.theme.package != null then sddmCfg.theme.package else pkgs.sddm-astronaut;
in
{
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = lib.count (x: x) [
            sddmCfg.enable
          ] <= 1;
          message = "Only one display manager can be enabled at a time.";
        }
        {
          assertion = !sddmCfg.enable || cfg.enable;
          message = "qnix.desktop.displaymanager.enable must be true when SDDM is enabled.";
        }
      ];
    }

    (lib.mkIf (cfg.enable && sddmCfg.enable) {
      environment.systemPackages =
        [ pkgs.kdePackages.qtmultimedia ]
        ++ lib.optional (themePackage != null) (
          themePackage.override { embeddedTheme = sddmCfg.theme.embeddedTheme; }
        );

      services.xserver.enable = true;

      services.displayManager.sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm;
        theme = sddmCfg.theme.name;
      };
    })
  ];
}
