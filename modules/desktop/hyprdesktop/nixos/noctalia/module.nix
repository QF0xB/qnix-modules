{ lib, config, ... }:

let
  cfg = config.qnix.desktop.hyprdesktop.noctalia;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.home.cache.directories = [
      ".cache/noctalia"
    ];
  };
}
