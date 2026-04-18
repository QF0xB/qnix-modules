{
  lib,
  config,
  options,
  pkgs,
  ...
}:
let
  cfg = config.qnix.network.wireguard;

  boolToNm = value: if value then "true" else "false";

  renderDns = servers: if servers == [ ] then null else "${lib.concatStringsSep ";" servers};";
  renderAllowedIPs =
    allowedIPs: if allowedIPs == [ ] then null else "${lib.concatStringsSep ";" allowedIPs};";

  renderAddresses =
    addresses:
    lib.listToAttrs (
      lib.imap0 (index: address: {
        name = "address${toString (index + 1)}";
        value = address;
      }) addresses
    );

  sanitizeEnvName =
    value:
    lib.toUpper (
      lib.replaceStrings
        [
          "-"
          "."
          " "
          ":"
          "/"
          "="
        ]
        [
          "_"
          "_"
          "_"
          "_"
          "_"
          "_"
        ]
        value
    );

  nmPrivateKeyEnvVar = tunnelName: "QNIX_WG_${sanitizeEnvName tunnelName}_PRIVATE_KEY";
  nmPresharedKeyEnvVar =
    tunnelName: peerName: "QNIX_WG_${sanitizeEnvName tunnelName}_${sanitizeEnvName peerName}_PSK";

  sopsPlaceholder =
    secretName: if secretName != null then config.sops.placeholder.${secretName} else "";

  hasSopsModule = options ? sops;

  networkManagerTunnels =
    if cfg.enable then
      lib.filterAttrs (_: tunnelCfg: tunnelCfg.backend == "networkmanager") cfg.tunnels
    else
      { };

  nmListenPorts = lib.unique (
    lib.filter (port: port != null) (
      lib.mapAttrsToList (_: tunnelCfg: tunnelCfg.listenPort) networkManagerTunnels
    )
  );

  nmProfiles = lib.mapAttrs (
    tunnelName: tunnelCfg:
    let
      interfaceName = if tunnelCfg.interfaceName != null then tunnelCfg.interfaceName else tunnelName;

      peerSections = lib.mapAttrs' (
        peerName: peerCfg:
        lib.nameValuePair "wireguard-peer.${peerCfg.publicKey}" (
          {
            "allowed-ips" = renderAllowedIPs peerCfg.allowedIPs;
          }
          // lib.optionalAttrs (peerCfg.endpoint != null) {
            endpoint = peerCfg.endpoint;
          }
          // lib.optionalAttrs (peerCfg.persistentKeepalive != null) {
            "persistent-keepalive" = peerCfg.persistentKeepalive;
          }
          // lib.optionalAttrs (peerCfg.presharedKey.sopsSecret != null) {
            "preshared-key" = "$" + "{${nmPresharedKeyEnvVar tunnelName peerName}}";
            "preshared-key-flags" = 0;
          }
        )
      ) tunnelCfg.peers;
    in
    {
      connection = {
        id = tunnelName;
        type = "wireguard";
        interface-name = interfaceName;
        autoconnect = boolToNm tunnelCfg.autoconnect;
      };

      wireguard = {
        "private-key" = "$" + "{${nmPrivateKeyEnvVar tunnelName}}";
        "peer-routes" = boolToNm tunnelCfg.routing.peerRoutes;
      }
      // lib.optionalAttrs (tunnelCfg.listenPort != null) {
        "listen-port" = tunnelCfg.listenPort;
      }
      // lib.optionalAttrs (tunnelCfg.mtu != null) {
        mtu = tunnelCfg.mtu;
      };

      ipv4 =
        (renderAddresses tunnelCfg.addresses)
        // lib.optionalAttrs (tunnelCfg.dns != [ ]) {
          dns = renderDns tunnelCfg.dns;
        }
        // {
          method = if tunnelCfg.addresses == [ ] then "auto" else "manual";
        };

      ipv6.method = "disabled";
    }
    // peerSections
  ) networkManagerTunnels;

  nmSopsSecretNames = lib.unique (
    lib.concatLists (
      lib.mapAttrsToList (
        _tunnelName: tunnelCfg:
        [ tunnelCfg.privateKey.sopsSecret ]
        ++ lib.mapAttrsToList (_peerName: peerCfg: peerCfg.presharedKey.sopsSecret) tunnelCfg.peers
      ) networkManagerTunnels
    )
  );

  nmSecretNames = lib.filter (secretName: secretName != null) nmSopsSecretNames;

  nmSecretTemplates = lib.mapAttrs' (
    tunnelName: tunnelCfg:
    let
      templateName = "networkmanager-wireguard-${tunnelName}.env";

      peerLines = lib.mapAttrsToList (
        peerName: peerCfg:
        lib.optionalString (peerCfg.presharedKey.sopsSecret != null) ''
          ${nmPresharedKeyEnvVar tunnelName peerName}=${
            config.sops.placeholder.${peerCfg.presharedKey.sopsSecret}
          }
        ''
      ) tunnelCfg.peers;
    in
    lib.nameValuePair templateName {
      owner = "root";
      group = "root";
      mode = "0400";
      content = ''
        ${nmPrivateKeyEnvVar tunnelName}=${sopsPlaceholder tunnelCfg.privateKey.sopsSecret}
        ${lib.concatStringsSep "\n" peerLines}
      '';
    }
  ) networkManagerTunnels;

  nmSecretTemplatePaths = lib.mapAttrsToList (
    tunnelName: _tunnelCfg: config.sops.templates."networkmanager-wireguard-${tunnelName}.env".path
  ) networkManagerTunnels;

  secretDefaults = lib.genAttrs nmSecretNames (_: {
    owner = "root";
    group = "root";
    mode = "0400";
  });

  hasNetworkManagerTunnels = networkManagerTunnels != { };
in
{
  config = lib.mkMerge [
    {
      assertions =
        lib.mapAttrsToList (name: tunnelCfg: {
          assertion = tunnelCfg.addresses != [ ];
          message = "qnix.network.wireguard.tunnels.${name}.addresses must not be empty.";
        }) networkManagerTunnels
        ++ lib.mapAttrsToList (name: tunnelCfg: {
          assertion = tunnelCfg.privateKey.sopsSecret != null;
          message = "qnix.network.wireguard.tunnels.${name}.privateKey.sopsSecret must be set for the NetworkManager backend.";
        }) networkManagerTunnels
        ++ lib.mapAttrsToList (name: _tunnelCfg: {
          assertion = config.qnix.network.networkmanager.enable;
          message = "qnix.network.wireguard.tunnels.${name} requires qnix.network.networkmanager.enable.";
        }) networkManagerTunnels
        ++ lib.mapAttrsToList (name: _tunnelCfg: {
          assertion = config.qnix.security.sops.enable;
          message = "qnix.network.wireguard.tunnels.${name} requires qnix.security.sops.enable.";
        }) networkManagerTunnels
        ++ lib.mapAttrsToList (name: _tunnelCfg: {
          assertion = hasSopsModule;
          message = "qnix.network.wireguard.tunnels.${name} requires the upstream sops module to be imported.";
        }) networkManagerTunnels;
    }

    (lib.mkIf hasNetworkManagerTunnels {
      environment.systemPackages = [ pkgs.wireguard-tools ];

      qnix.security.sops.secrets = secretDefaults;

      networking.networkmanager.ensureProfiles = {
        profiles = nmProfiles;
        environmentFiles = nmSecretTemplatePaths;
      };
    })

    (lib.mkIf (hasSopsModule && hasNetworkManagerTunnels) {
      sops.templates = nmSecretTemplates;
    })

    (lib.mkIf (cfg.openFirewall && nmListenPorts != [ ]) {
      qnix.network.firewall.allowedUDPPorts = nmListenPorts;
    })
  ];
}
