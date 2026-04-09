{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  pkgs,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.desktop.sound or {
    enable = false;
    gui.enable = false;
  };
in
{
  config = lib.mkIf cfg.enable {
    home.packages =
      [ pkgs.playerctl ]
      ++ lib.optionals cfg.gui.enable [
        pkgs.easyeffects
        pkgs.pavucontrol
        pkgs.pamixer
      ];
  };
}
