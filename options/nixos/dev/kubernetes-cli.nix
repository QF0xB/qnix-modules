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

<<<<<<< HEAD
    k9sPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.k9s;
      defaultText = lib.literalExpression "pkgs.k9s";
      description = "k9s package (Home Manager programs.k9s.package).";
    };

    kubeCtxPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kubectx;
      description = "KubeCTX package";
    };

    k9sExtraPathPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ pkgs.kubelogin ];
      defaultText = lib.literalExpression "[ pkgs.kubelogin ]";
      description = ''
        Packages installed for your user and prepended to PATH for the wrapped `k9s`
        binary. Kubeconfig `exec` helpers (Azure `kubelogin`, other cluster auth plugins)
        must be visible to k9s; missing helpers often produce misleading `po` or
        `v1/pods` command-not-found errors for a context that still works in an
        interactive shell. Defaults to `kubelogin`; set to an empty list if unused.
      '';
=======
    freelensPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.freelens-bin;
      defaultText = lib.literalExpression "pkgs.freelens-bin";
      description = "Freelens package.";
>>>>>>> dc05296 (feat(kubernetes): add freelens application)
    };
  };
}
