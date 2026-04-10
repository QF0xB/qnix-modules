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
  cfg = qconfig.dev.postman or { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
