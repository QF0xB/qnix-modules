{ lib, ... }:
{
  options.qnix.security.firewall = {
    enable = lib.mkEnableOption "firewall";

    allowedTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "The TCP ports that are allowed to be used.";
    };

    allowedUDPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "The UDP ports that are allowed to be used.";
    };

    allowPing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow pinging the machine.";
    };
  };
}
