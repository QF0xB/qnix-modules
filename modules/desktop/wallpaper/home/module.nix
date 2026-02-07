{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.desktop.waypaper;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.waypaper
    ];

    services.swww = {
      enable = true;
    };

    # Set default wallpaper after swww daemon starts
    systemd.user.services.swww-set-wallpaper = lib.mkIf (cfg.defaultWallpaper != null) {
      Unit = {
        Description = "Set default wallpaper for swww";
        After = [ "swww.service" ];
        Requires = [ "swww.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.swww}/bin/swww img %h/Pictures/wallpaper/${cfg.defaultWallpaper}";
        RemainAfterExit = false;
      };
    };

    # Copy wallpapers to ~/Pictures/wallpaper if source is specified
    home.file = lib.mkIf (cfg.wallpaperSource != null) {
      "Pictures/wallpaper" = {
        source = cfg.wallpaperSource;
        recursive = true;
      };
    };
  };
}
