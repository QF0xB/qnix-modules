{ lib, osConfig, ... }:

let
  cfg = osConfig.qnix.core.stylix.wallpapers;
in
{
  config = lib.mkIf cfg.enable {
    home.file."Pictures/wallpaper" = {
      source = cfg.wallpapersPath;
      recursive = true;
    };
  };
}
