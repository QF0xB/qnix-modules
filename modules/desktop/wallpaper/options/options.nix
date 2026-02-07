{
  lib,
  config ? null,
  ...
}:

{
  options.qnix.desktop.waypaper = {
    enable = lib.mkEnableOption "waypaper" // {
      default = config != null && config.qnix.wayland && !config.qnix.headless;
    };

    wallpaperSource = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = ../assets;
      description = "Source directory containing wallpapers to copy to ~/Pictures/wallpaper";
    };

    defaultWallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "solarized-dark.png";
      description = "Default wallpaper filename to use (relative to ~/Pictures/wallpaper)";
    };
  };
}
