# DNS records for appliances live in NixOS: `qnix.network.coredns.staticHosts` (or `corefile`).
{ ... }:
{
  imports = [ ./server.nix ];
}
