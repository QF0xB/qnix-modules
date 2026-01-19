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
  };
}
