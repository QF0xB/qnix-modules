{ lib, config, ... }:

let
  cfg = config.qnix.core.network.firewall;
in
{
  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        enable = true;

        allowedTCPPorts = cfg.allowedTCPPorts;
        allowedUDPPorts = cfg.allowedUDPPorts;

        allowPing = cfg.allowPing;

        allowedTCPPortRanges = cfg.allowedTCPPortRanges;
        allowedUDPPortRanges = cfg.allowedUDPPortRanges;

        rejectPackets = cfg.rejectPackets;
      };
    };
  };
}
