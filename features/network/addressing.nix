{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    let
      address = lib.types.submodule {
        options = {
          address = lib.mkOption {
            type = lib.types.str;
            description = "The IP address.";
          };

          prefixLength = lib.mkOption {
            type = lib.types.ints.between 0 128;
            description = "The network prefix length.";
          };
        };
      };

      route = lib.types.submodule {
        options = {
          address = lib.mkOption {
            type = lib.types.str;
            description = "The destination network address.";
          };

          prefixLength = lib.mkOption {
            type = lib.types.ints.between 0 128;
            description = "The destination network prefix length.";
          };

          via = lib.mkOption {
            type = lib.types.str;
            description = "The gateway used for this route.";
          };
        };
      };

      addressFamily = lib.types.submodule {
        options = {
          addresses = lib.mkOption {
            type = lib.types.listOf address;
            default = [ ];
            description = "Static addresses for this address family.";
          };

          routes = lib.mkOption {
            type = lib.types.listOf route;
            default = [ ];
            description = "Static routes for this address family.";
          };
        };
      };

      interface = lib.types.submodule {
        options = {
          useDHCP = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether DHCP should configure this interface.";
          };

          ipv4 = lib.mkOption {
            type = addressFamily;
            default = { };
            description = "IPv4 addressing and routes.";
          };

          ipv6 = lib.mkOption {
            type = addressFamily;
            default = { };
            description = "IPv6 addressing and routes.";
          };
        };
      };

      gateway = lib.types.submodule {
        options = {
          address = lib.mkOption {
            type = lib.types.str;
            description = "The default gateway address.";
          };

          interface = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "The interface used by the default gateway.";
          };

          metric = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "The default gateway metric.";
          };

          source = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "The source address used by the default gateway.";
          };
        };
      };

      gatewayType = lib.types.nullOr (
        lib.types.coercedTo lib.types.str (value: { address = value; }) gateway
      );
    in
    {
      hostname = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The system hostname.";
      };

      hostId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The 32-bit host ID used by ZFS and networking.";
      };

      nameservers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Nameservers used by the system.";
      };

      defaultGateway = lib.mkOption {
        type = gatewayType;
        default = null;
        description = "The IPv4 default gateway.";
      };

      defaultGateway6 = lib.mkOption {
        type = gatewayType;
        default = null;
        description = "The IPv6 default gateway.";
      };

      interfaces = lib.mkOption {
        type = lib.types.attrsOf interface;
        default = { };
        description = "Interface addressing, DHCP, and static routes.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      ...
    }:
    let
      mapAddress = value: {
        inherit (value) address prefixLength;
      };

      mapRoute = value: {
        inherit (value) address prefixLength via;
      };

      mapFamily = value: {
        addresses = map mapAddress value.addresses;
        routes = map mapRoute value.routes;
      };

      mapInterface = value: {
        useDHCP = value.useDHCP;
        ipv4 = mapFamily value.ipv4;
        ipv6 = mapFamily value.ipv6;
      };
    in
    {
      networking = lib.mkMerge [
        (lib.mkIf (cfg.hostname != null) { hostName = cfg.hostname; })
        (lib.mkIf (cfg.hostId != null) { hostId = cfg.hostId; })
        (lib.mkIf (cfg.nameservers != [ ]) { nameservers = cfg.nameservers; })
        (lib.mkIf (cfg.defaultGateway != null) { defaultGateway = cfg.defaultGateway; })
        (lib.mkIf (cfg.defaultGateway6 != null) { defaultGateway6 = cfg.defaultGateway6; })
        { interfaces = lib.mapAttrs (_: mapInterface) cfg.interfaces; }
      ];
    };
}
