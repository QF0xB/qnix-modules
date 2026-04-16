{ lib, ... }:
{
  imports = lib.concatLists [
    [ ./server.nix ]
    (lib.qnix.mkNixosFeatureImports {
      category = "runtime";
      name = "kubernetes/k3s";
    })
  ];

  config.qnix.runtime.k3s = {
    enable = lib.mkDefault true;
    role = lib.mkDefault "agent";
  };
}
