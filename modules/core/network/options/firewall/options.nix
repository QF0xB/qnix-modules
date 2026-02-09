{ lib, ... }:

{
  options.qnix.core.network.firewall = {
    enable = lib.mkEnableOption "firewall" // {
      default = true;
    };

    allowedTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "List of TCP ports to allow";
    };

    allowedUDPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "List of UDP ports to allow";
    };

    allowPing = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to allow ping";
    };

    allowedTCPPortRanges = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of TCP port ranges to allow";
    };

    allowedUDPPortRanges = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of UDP port ranges to allow";
    };

    rejectPackets = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to reject packets";
    };
  };
}
