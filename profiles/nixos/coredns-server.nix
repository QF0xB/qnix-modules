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
    # RFC 5737 TEST-NET-1 documentation addresses — replace in host `qnix.nix` with your LAN.
    staticHosts = lib.mkDefault {
      "gw.example.test" = "192.0.2.1";
      "dns-a.example.test" = "192.0.2.53";
      "dns-b.example.test" = "192.0.2.54";
    };
  };
}
