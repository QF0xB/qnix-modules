{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.network.wireguard;

  boolToNm = value: if value then "true" else "false";

  renderDns = servers: if servers == [ ] then null else "${lib.concatStringsSep ";" servers};";

  renderAllowedIPs = allowedIPs: if allowedIPs == [ ] then null else "${lib.concatStringsSep ";" allowedIPs};";

  renderAddresses =
    addresses:
    lib.listToAttrs (
      lib.imap0 (index: address: {
        name = "address${toString (index + 1)}";
        value = address;
      }) addresses
    );

  renderedInterfaces = lib.mapAttrs (
    _: interfaceCfg:
    {
      inherit (interfaceCfg)
        ips
        table
        peers
        allowedIPsAsRoutes
        dynamicEndpointRefreshSeconds
        preSetup
        postSetup
        preShutdown
        postShutdown
        ;
    }
    // lib.optionalAttrs (interfaceCfg.privateKeyFile != null) {
      privateKeyFile = interfaceCfg.privateKeyFile;
    }
    // lib.optionalAttrs (interfaceCfg.listenPort != null) {
      listenPort = interfaceCfg.listenPort;
    }
    // lib.optionalAttrs (interfaceCfg.mtu != null) {
      mtu = interfaceCfg.mtu;
    }
  ) cfg.interfaces;

  listenPorts = lib.unique (
    lib.filter (port: port != null) (lib.mapAttrsToList (_: interfaceCfg: interfaceCfg.listenPort) cfg.interfaces)
  );

  nmConnections = cfg.networkManager.connections;

  nmListenPorts = lib.unique (
    lib.filter (port: port != null) (lib.mapAttrsToList (_: connectionCfg: connectionCfg.listenPort) nmConnections)
  );

  nmProfiles = lib.mapAttrs (
    connectionId: connectionCfg:
    let
      peerSections = lib.listToAttrs (
        map (peerCfg: {
          name = "wireguard-peer.${peerCfg.publicKey}";
          value =
            {
              "allowed-ips" = renderAllowedIPs peerCfg.allowedIPs;
            }
            // lib.optionalAttrs (peerCfg.endpoint != null) {
              endpoint = peerCfg.endpoint;
            }
            // lib.optionalAttrs (peerCfg.persistentKeepalive != null) {
              "persistent-keepalive" = peerCfg.persistentKeepalive;
            }
            // lib.optionalAttrs (peerCfg.presharedKeySecretName != null) {
              "preshared-key-flags" = 0;
            };
        }) connectionCfg.peers
      );
    in
    {
      connection = {
        id = connectionId;
        type = "wireguard";
        interface-name = connectionCfg.interfaceName;
        autoconnect = boolToNm connectionCfg.autoconnect;
      };

      wireguard =
        {
          "private-key-flags" = 0;
          "peer-routes" = boolToNm connectionCfg.peerRoutes;
        }
        // lib.optionalAttrs (connectionCfg.listenPort != null) {
          "listen-port" = connectionCfg.listenPort;
        }
        // lib.optionalAttrs (connectionCfg.mtu != null) {
          mtu = connectionCfg.mtu;
        };

      ipv4 =
        (renderAddresses connectionCfg.addresses)
        // lib.optionalAttrs (connectionCfg.dns != [ ]) {
          dns = renderDns connectionCfg.dns;
        }
        // {
          method = if connectionCfg.addresses == [ ] then "auto" else "manual";
        };

      ipv6.method = "disabled";
    }
    // peerSections
  ) nmConnections;

  nmSecretEntries = lib.concatLists (
    lib.mapAttrsToList (
      connectionId: connectionCfg:
      [
        {
          matchId = connectionId;
          matchType = "wireguard";
          matchSetting = "wireguard";
          key = "private-key";
          file = config.sops.secrets.${connectionCfg.privateKeySecretName}.path;
        }
      ]
      ++ map (peerCfg: {
        matchId = connectionId;
        matchType = "wireguard";
        matchSetting = "wireguard";
        key = "peers.${peerCfg.publicKey}.preshared-key";
        file = config.sops.secrets.${peerCfg.presharedKeySecretName}.path;
      }) (lib.filter (peerCfg: peerCfg.presharedKeySecretName != null) connectionCfg.peers)
    ) nmConnections
  );

  nmSecretNames = lib.unique (
    lib.concatLists (
      lib.mapAttrsToList (
        _: connectionCfg:
        [ connectionCfg.privateKeySecretName ]
        ++ map (peerCfg: peerCfg.presharedKeySecretName) (
          lib.filter (peerCfg: peerCfg.presharedKeySecretName != null) connectionCfg.peers
        )
      ) nmConnections
    )
  );

  secretDefaults = lib.genAttrs nmSecretNames (_: {
    owner = "root";
    group = "root";
    mode = "0400";
  });
in
{
  config = lib.mkMerge [
    {
      assertions =
        lib.mapAttrsToList (name: interfaceCfg: {
          assertion = !cfg.enable || interfaceCfg.privateKeyFile != null;
          message = "qnix.network.wireguard.interfaces.${name}.privateKeyFile must be set.";
        }) cfg.interfaces
        ++ lib.mapAttrsToList (name: interfaceCfg: {
          assertion = !cfg.enable || interfaceCfg.ips != [ ];
          message = "qnix.network.wireguard.interfaces.${name}.ips must not be empty.";
        }) cfg.interfaces
        ++ lib.mapAttrsToList (name: connectionCfg: {
          assertion = connectionCfg.addresses != [ ];
          message = "qnix.network.wireguard.networkManager.connections.${name}.addresses must not be empty.";
        }) nmConnections
        ++ lib.mapAttrsToList (_: _: {
          assertion = config.qnix.network.networkmanager.enable;
          message = "qnix.network.wireguard.networkManager.connections requires qnix.network.networkmanager.enable.";
        }) nmConnections
        ++ lib.mapAttrsToList (_: _: {
          assertion = config.qnix.security.sops.enable;
          message = "qnix.network.wireguard.networkManager.connections requires qnix.security.sops.enable.";
        }) nmConnections;
    }

    (lib.mkIf cfg.enable {
      networking.wireguard.interfaces = renderedInterfaces;
    })

    (lib.mkIf (nmConnections != { }) {
      environment.systemPackages = [ pkgs.wireguard-tools ];

      qnix.security.sops.secrets = secretDefaults;

      networking.networkmanager.ensureProfiles = {
        profiles = nmProfiles;
        secrets.entries = nmSecretEntries;
      };
    })

    (lib.mkIf (cfg.openFirewall && (listenPorts ++ nmListenPorts) != [ ]) {
      networking.firewall.allowedUDPPorts = lib.unique (listenPorts ++ nmListenPorts);
    })
  ];
}
