{ lib, config, ... }:
let
  cfg = config.qnix.system.thunderbolt;
in
{
  config = {
    services.hardware.bolt = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
