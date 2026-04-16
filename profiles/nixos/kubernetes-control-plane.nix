{ lib, ... }:
{
  imports = lib.concatLists [
    [ ./server.nix ]
    (lib.qnix.mkNixosFeatureImports {
      category = "runtime";
      name = "kubernetes/k3s";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "runtime";
      name = "kubernetes/kube-vip-api";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "runtime";
      name = "kubernetes/kube-vip-lb";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "runtime";
      name = "kubernetes/flux";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "runtime";
      name = "kubernetes/observability";
    })
  ];

  config.qnix = {
    runtime = {
      k3s = {
        enable = lib.mkDefault true;
        role = lib.mkDefault "server";
      };

      kubeVipApi.enable = lib.mkDefault true;
      kubeVipLb.enable = lib.mkDefault false;
      flux.enable = lib.mkDefault true;
      observability.enable = lib.mkDefault true;
    };
  };
}
