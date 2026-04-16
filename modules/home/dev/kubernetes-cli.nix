{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.dev.kubernetesCli;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.kubectlPackage
      cfg.helmPackage
      cfg.kustomizePackage
      cfg.fluxPackage
    ];
  };
}
