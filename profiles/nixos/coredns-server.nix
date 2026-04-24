{ lib, ... }:
{
  imports = [ ./server.nix ] ++ lib.concatLists [
    (lib.qnix.mkNixosFeatureImports {
      category = "network";
      name = "coredns";
    })
  ];

  config.qnix.network.coredns = {
    enable = lib.mkDefault true;
  };
}
