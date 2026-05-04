{ lib, config, ... }:
let
  cfg = config.qnix.dev.kubernetesCli;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".kube"
      ".config/Freelens"
    ];
  };
}
