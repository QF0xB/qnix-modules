{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.desktop.terminal;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
