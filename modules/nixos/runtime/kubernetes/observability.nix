{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.runtime.observability;
  k3sCfg = config.qnix.runtime.k3s;
  fluxCfg = config.qnix.runtime.flux;
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = k3sCfg.enable && k3sCfg.role == "server";
        message = "qnix.runtime.observability requires qnix.runtime.k3s.enable with role = \"server\".";
      }
      {
        assertion = fluxCfg.enable;
        message = "qnix.runtime.observability is Flux-managed; enable qnix.runtime.flux.";
      }
    ];
  };
}
