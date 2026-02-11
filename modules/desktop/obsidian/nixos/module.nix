{ lib, config, ... }:

let
  cfg = config.qnix.desktop.obsidian;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.home.directories = [
      ".config/obsidian"
    ];
  };
}
