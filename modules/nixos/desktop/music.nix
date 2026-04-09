{ lib, config, ... }:
let
  cfg = config.qnix.desktop.music;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".config/tidal-hifi"
    ];
  };
}
