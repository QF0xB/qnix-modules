{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.desktop.hyprdesktop.dms;
in
{

  imports = [
    (inputs.dms.homeModules.dank-material-shell)
  ];

  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      enableSystemMonitoring = true;
      systemd.enable = true;
    };
  };
}
