{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.desktop.dev-utilities;
  enabled = cfg.enable || cfg.postman.enable;
in
{
  config = lib.mkIf enabled {
    qnix.persist.home.directories = [
      ".config/Postman"
    ];
  };
}
