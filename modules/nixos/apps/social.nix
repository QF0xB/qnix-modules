{ lib, config, ... }:
let
  cfg = config.qnix.apps.social;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = cfg.persistDirectories;
  };
}
