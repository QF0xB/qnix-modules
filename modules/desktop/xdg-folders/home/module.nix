{ lib, osConfig, ... }:

let
  cfg = osConfig.qnix.desktop.xdg-folders;
in
{
  config = lib.mkIf cfg.enable {
    xdg.userDirs = {
      enable = true;

      createDirectories = true;
    };
  };
}
