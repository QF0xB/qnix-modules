{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.desktop.music or { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
