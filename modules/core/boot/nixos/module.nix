{ lib, config, ... }:

let
  cfg = config.qnix.boot;
in
{
  config = lib.mkIf cfg.enable {
    # NixOS configuration for boot
  };
}
