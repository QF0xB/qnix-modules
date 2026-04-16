{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.runtime.kubeVipApi;
  k3sCfg = config.qnix.runtime.k3s;
  kubeVipManifest = ''
    apiVersion: v1
    kind: Pod
    metadata:
      name: kube-vip
      namespace: kube-system
    spec:
      hostNetwork: true
      containers:
        - name: kube-vip
          image: ${cfg.image}
          args:
            - manager
          env:
            - name: vip_arp
              value: "true"
            - name: address
              value: "${cfg.address}"
            - name: port
              value: "6443"
            - name: vip_interface
              value: "${cfg.interface}"
            - name: cp_enable
              value: "true"
          securityContext:
            capabilities:
              add:
                - NET_ADMIN
                - NET_RAW
      tolerations:
        - operator: Exists
  '';
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = k3sCfg.enable && k3sCfg.role == "server";
        message = "qnix.runtime.kubeVipApi requires qnix.runtime.k3s.enable with role = \"server\".";
      }
    ];

    environment.etc."rancher/k3s/server/manifests/${cfg.manifestFileName}".text = kubeVipManifest;
  };
}
