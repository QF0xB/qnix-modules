{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.system.packages;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.editor
    ]
    ++ cfg.extra;
  };
}
