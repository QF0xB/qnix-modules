{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.desktop.openrgb;
in
{
  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      startupProfile = "QPC.orp";
    };

    qnix.persist.home.directories = [
      ".config/OpenRGB"
    ];
  };
}
