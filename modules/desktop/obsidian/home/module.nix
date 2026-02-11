{ lib, osConfig, ... }:

let
  cfg = osConfig.qnix.desktop.obsidian;
in
{
  config = lib.mkIf cfg.enable {
    programs.obsidian = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
