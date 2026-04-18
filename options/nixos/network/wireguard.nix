{ lib, ... }:
let
  secretSourceType = lib.types.submodule {
    options = {
      sopsSecret = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "SOPS secret name containing the secret.";
      };
    };
  };

  routingType = lib.types.submodule {
    options = {
      peerRoutes = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether NetworkManager should install routes for peer AllowedIPs.";
      };
    };
  };

  tunnelPeerType = lib.types.submodule {
    options = {
      publicKey = lib.mkOption {
        type = lib.types.str;
        description = "Base64 public key of the remote WireGuard peer.";
      };

      allowedIPs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "CIDR ranges routed to this peer.";
      };

      endpoint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional peer endpoint in host:port form.";
      };

      presharedKey = lib.mkOption {
        type = secretSourceType;
        default = { };
        description = "Optional preshared key source.";
      };

      persistentKeepalive = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional persistent keepalive interval in seconds.";
      };
    };
  };

  tunnelType = lib.types.submodule {
    options = {
      backend = lib.mkOption {
        type = lib.types.enum [ "networkmanager" ];
        default = "networkmanager";
        description = "WireGuard backend for this tunnel. Currently only NetworkManager is supported.";
      };

      interfaceName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Interface name exposed by NetworkManager. Defaults to the tunnel name.";
      };

      autoconnect = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether NetworkManager should automatically bring up the tunnel.";
      };

      addresses = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "IPv4 or IPv6 addresses assigned to the WireGuard tunnel.";
      };

      dns = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "DNS servers configured on the tunnel.";
      };

      privateKey = lib.mkOption {
        type = secretSourceType;
        default = { };
        description = "Private key source for this tunnel.";
      };

      listenPort = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional WireGuard listen port.";
      };

      mtu = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional MTU override.";
      };

      routing = lib.mkOption {
        type = routingType;
        default = { };
        description = "Routing behavior for this tunnel.";
      };

      peers = lib.mkOption {
        type = lib.types.attrsOf tunnelPeerType;
        default = { };
        description = "Remote peers for this tunnel.";
      };
    };
  };

in
{
  options.qnix.network.wireguard = {
    enable = lib.mkEnableOption "WireGuard networking";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for explicitly configured listen ports.";
    };

    tunnels = lib.mkOption {
      type = lib.types.attrsOf tunnelType;
      default = { };
      description = "Declarative WireGuard tunnels. New configurations should use this option.";
    };
  };
}
