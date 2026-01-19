{ lib, config, ... }:

let
  cfg = config.qnix.desktop.waypaper;
in
{
  config = lib.mkIf cfg.enable {
    # NixOS configuration for waypaper
  };
}
