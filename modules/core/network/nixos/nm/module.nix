{ lib, config, ... }:

let
  cfg = config.qnix.core.network.nm;
in
{
  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;

        unmanaged = cfg.unmanaged;

        plugins = cfg.extraPlugins;
      };
    };
  };
}
