{ lib, config, ... }:

let
  cfg = config.qnix.network.firewall;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      enable = true;

      allowedTCPPorts = cfg.allowedTCPPorts;
      allowedUDPPorts = cfg.allowedUDPPorts;
      allowPing = cfg.allowPing;
    };
  };
}
