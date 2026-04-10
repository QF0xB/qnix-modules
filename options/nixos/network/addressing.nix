{ lib, ... }:
let
  addressType = lib.types.submodule {
    options = {
      address = lib.mkOption {
        type = lib.types.str;
        description = "IP address.";
      };

      prefixLength = lib.mkOption {
        type = lib.types.int;
        description = "CIDR prefix length.";
      };
    };
  };

  interfaceType = lib.types.submodule {
    options = {
      useDHCP = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether this interface should use DHCP.";
      };

      ipv4.addresses = lib.mkOption {
        type = lib.types.listOf addressType;
        default = [ ];
        description = "Static IPv4 addresses for this interface.";
      };

      ipv6.addresses = lib.mkOption {
        type = lib.types.listOf addressType;
        default = [ ];
        description = "Static IPv6 addresses for this interface.";
      };
    };
  };
in
{
  options.qnix.network.addressing = {
    hostName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional host name to set through networking.hostName.";
    };

    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Nameservers to configure.";
    };

    defaultGateway = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default IPv4 gateway address.";
    };

    defaultGatewayInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional interface for the default IPv4 gateway.";
    };

    defaultGateway6 = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default IPv6 gateway address.";
    };

    defaultGateway6Interface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional interface for the default IPv6 gateway.";
    };

    interfaces = lib.mkOption {
      type = lib.types.attrsOf interfaceType;
      default = { };
      description = "Per-interface addressing configuration.";
    };
  };
}
