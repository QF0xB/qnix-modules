{
  lib,
  ...
}:
{
  options.qnix.runtime.kubeVipApi = {
    enable = lib.mkEnableOption "kube-vip API virtual IP management";

    address = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0.10";
      description = "Virtual IP used for the Kubernetes API endpoint.";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "Network interface kube-vip should bind to.";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/kube-vip/kube-vip:v0.8.2";
      description = "Container image reference for kube-vip.";
    };

    manifestFileName = lib.mkOption {
      type = lib.types.str;
      default = "qnix-kube-vip-api.yaml";
      description = "Manifest file name written into the k3s static-manifest directory.";
    };
  };
}
