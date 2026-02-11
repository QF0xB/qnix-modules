{
  lib,
  config,
  ...
}:

let
  cfg = config.qnix.desktop.tidal-hifi;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.home.directories = [
      ".config/tidal-hifi"
    ];
  };
}
