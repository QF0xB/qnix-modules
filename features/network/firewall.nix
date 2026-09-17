{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [ ];
        description = "TCP ports allowed through the firewall.";
      };

      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [ ];
        description = "UDP ports allowed through the firewall.";
      };

      allowPing = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether ICMP echo requests may reach the host.";
      };
    };

  nixos =
    {
      cfg,
      ...
    }:
    {
      networking.firewall = {
        enable = true;
        allowedTCPPorts = cfg.allowedTCPPorts;
        allowedUDPPorts = cfg.allowedUDPPorts;
        allowPing = cfg.allowPing;
      };
    };
}
