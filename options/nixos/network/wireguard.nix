{ lib, ... }:
let
  peerType = lib.types.submodule {
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

      presharedKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional file path containing the peer preshared key.";
      };

      persistentKeepalive = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional persistent keepalive interval in seconds.";
      };

      dynamicEndpointRefreshSeconds = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional peer-specific endpoint refresh interval in seconds.";
      };
    };
  };

  interfaceType = lib.types.submodule {
    options = {
      ips = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "IP addresses to assign to the WireGuard interface.";
      };

      privateKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "File path containing the WireGuard private key.";
      };

      listenPort = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional UDP listen port for the interface.";
      };

      table = lib.mkOption {
        type = lib.types.str;
        default = "main";
        description = "Routing table used for peer routes.";
      };

      allowedIPsAsRoutes = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether peer allowed IPs should be installed as routes.";
      };

      mtu = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional MTU override for the interface.";
      };

      dynamicEndpointRefreshSeconds = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = "Interface-wide endpoint refresh interval in seconds.";
      };

      preSetup = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Shell commands to run before the interface is set up.";
      };

      postSetup = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Shell commands to run after the interface is set up.";
      };

      preShutdown = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Shell commands to run before the interface is shut down.";
      };

      postShutdown = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Shell commands to run after the interface is shut down.";
      };

      peers = lib.mkOption {
        type = lib.types.listOf peerType;
        default = [ ];
        description = "Remote peers connected to this WireGuard interface.";
      };
    };
  };

  networkManagerPeerType = lib.types.submodule {
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

      presharedKeySecretName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Name of the sops secret containing the peer preshared key.";
      };

      persistentKeepalive = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional persistent keepalive interval in seconds.";
      };
    };
  };

  networkManagerConnectionType = lib.types.submodule {
    options = {
      interfaceName = lib.mkOption {
        type = lib.types.str;
        default = "wg0";
        description = "Interface name exposed by NetworkManager for this WireGuard connection.";
      };

      autoconnect = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether NetworkManager should automatically bring up the connection.";
      };

      addresses = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "IPv4 or IPv6 addresses assigned to the WireGuard connection.";
      };

      dns = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "DNS servers configured on the connection.";
      };

      privateKeySecretName = lib.mkOption {
        type = lib.types.str;
        description = "Name of the sops secret containing the WireGuard private key.";
      };

      listenPort = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional WireGuard listen port for the NetworkManager connection.";
      };

      mtu = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Optional MTU override for the connection.";
      };

      peerRoutes = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether NetworkManager should install routes for peer AllowedIPs.";
      };

      peers = lib.mkOption {
        type = lib.types.listOf networkManagerPeerType;
        default = [ ];
        description = "Remote peers for the NetworkManager WireGuard connection.";
      };
    };
  };
in
{
  options.qnix.network.wireguard = {
    enable = lib.mkEnableOption "WireGuard client networking";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for explicitly configured listen ports.";
    };

    interfaces = lib.mkOption {
      type = lib.types.attrsOf interfaceType;
      default = { };
      description = "Declarative WireGuard interface definitions.";
    };

    networkManager.connections = lib.mkOption {
      type = lib.types.attrsOf networkManagerConnectionType;
      default = { };
      description = "Declarative NetworkManager WireGuard connections backed by sops-managed secrets.";
    };
  };
}
