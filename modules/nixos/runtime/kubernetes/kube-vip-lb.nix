{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.runtime.kubeVipLb;
  k3sCfg = config.qnix.runtime.k3s;
  cidrLine =
    if cfg.cidr == null then
      ""
    else
      "        - name: vip_cidr\n          value: \"${toString cfg.cidr}\"";
  manifest = ''
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: kube-vip
      namespace: kube-system
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kube-vip-role
    rules:
      - apiGroups: [""]
        resources: ["services", "services/status", "endpoints", "nodes"]
        verbs: ["list", "get", "watch", "update", "patch"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: kube-vip-binding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: kube-vip-role
    subjects:
      - kind: ServiceAccount
        name: kube-vip
        namespace: kube-system
    ---
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: kube-vip-ds
      namespace: kube-system
    spec:
      selector:
        matchLabels:
          app.kubernetes.io/name: kube-vip-ds
      template:
        metadata:
          labels:
            app.kubernetes.io/name: kube-vip-ds
        spec:
          serviceAccountName: kube-vip
          hostNetwork: true
          containers:
            - name: kube-vip
              image: ${cfg.image}
              args:
                - manager
              env:
                - name: vip_interface
                  value: "${cfg.interface}"
                - name: svc_enable
                  value: "true"
    ${cidrLine}
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
        message = "qnix.runtime.kubeVipLb requires qnix.runtime.k3s.enable with role = \"server\".";
      }
    ];

    environment.etc."rancher/k3s/server/manifests/${cfg.manifestFileName}".text = manifest;
  };
}
