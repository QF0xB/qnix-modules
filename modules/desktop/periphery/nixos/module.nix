{ lib, config, ... }:

let
  cfg = config.qnix.desktop.periphery;
in
{
  config = lib.mkIf cfg.enable {
    # NixOS configuration for periphery
  };
}
