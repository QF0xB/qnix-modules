{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.dev.nixfmt;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nixfmt ];
  };
}
