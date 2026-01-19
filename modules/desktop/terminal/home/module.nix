{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.desktop.terminal;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kitty ];
  };
}
