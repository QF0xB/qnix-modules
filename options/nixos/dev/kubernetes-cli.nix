{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.dev.kubernetesCli = {
    enable = lib.mkEnableOption "Kubernetes CLI tooling for clients";

    kubectlPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kubectl;
      defaultText = lib.literalExpression "pkgs.kubectl";
      description = "kubectl package.";
    };

    helmPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kubernetes-helm;
      defaultText = lib.literalExpression "pkgs.kubernetes-helm";
      description = "Helm package.";
    };

    kustomizePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kustomize;
      defaultText = lib.literalExpression "pkgs.kustomize";
      description = "kustomize package.";
    };

    fluxPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fluxcd;
      defaultText = lib.literalExpression "pkgs.fluxcd";
      description = "Flux CLI package.";
    };
  };
}
