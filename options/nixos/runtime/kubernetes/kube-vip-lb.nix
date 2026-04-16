{
  lib,
  ...
}:
{
  options.qnix.runtime.kubeVipLb = {
    enable = lib.mkEnableOption "kube-vip service LoadBalancer support";

    interface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "Network interface kube-vip should advertise service VIPs on.";
    };

    cidr = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Optional CIDR mask kube-vip should use for service VIP announcements.";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/kube-vip/kube-vip:v0.8.2";
      description = "Container image reference for kube-vip.";
    };

    manifestFileName = lib.mkOption {
      type = lib.types.str;
      default = "qnix-kube-vip-lb.yaml";
      description = "Manifest file name written into the k3s static-manifest directory.";
    };
  };
}
