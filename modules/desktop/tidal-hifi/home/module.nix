{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.desktop.tidal-hifi;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.tidal-hifi
    ];
  };
}
