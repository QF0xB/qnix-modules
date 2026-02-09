{ lib, config, ... }:

let
  cfg = config.qnix.desktop.periphery;
in
{
  config = {
    services.hardware.bolt = lib.mkIf cfg.thunderbolt.enable {
      enable = true;
    };
  };
}
