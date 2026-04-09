{ lib, config, ... }:
let
  cfg = config.qnix.apps.music;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".config/tidal-hifi"
    ];
  };
}
