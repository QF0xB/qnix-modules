{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.dev.devenv;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.devenv ];
  };
}
