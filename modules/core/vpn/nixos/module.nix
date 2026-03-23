{ lib, config, pkgs, ... }:

let
  cfg = config.qnix.core.vpn;
in
{
  config = lib.mkIf (cfg.enable && cfg.openvpn.enable) {
    # Create /etc/openvpn/<serverName>/... from the files passed in via options.
    environment.etc =
      lib.mkMerge [
        (lib.listToAttrs
          (lib.concatLists
            (lib.mapAttrsToList
              (serverName: serverCfg:
                lib.mapAttrsToList
                  (filePath: fileCfg: {
                    name = "openvpn/${serverName}/${filePath}";
                    value = {
                      source = pkgs.writeText
                        "openvpn-${serverName}-${lib.replaceStrings ["/"] ["-"] filePath}"
                        fileCfg.content;
                      mode = fileCfg.mode;
                    };
                  })
                  serverCfg.files)
              cfg.openvpn.servers)))
      ];

    # Translate our wrapper options into the upstream NixOS OpenVPN module.
    services.openvpn.servers =
      let
        mkOpenVPNConfig = serverName: serverCfg:
          if serverCfg.config != null then serverCfg.config
          else if serverCfg.configFile != null then
            "config /etc/openvpn/${serverName}/${serverCfg.configFile}"
          else if serverCfg.files ? "config.ovpn" then
            "config /etc/openvpn/${serverName}/config.ovpn"
          else
            null;
      in
      lib.mapAttrs
        (serverName: serverCfg: {
          config = mkOpenVPNConfig serverName serverCfg;
          updateResolvConf = serverCfg.updateResolvConf;
          up = serverCfg.up;
          down = serverCfg.down;
          autoStart = serverCfg.autoStart;
          authUserPass = serverCfg.authUserPass;
        })
        (lib.filterAttrs
          (serverName: serverCfg: (mkOpenVPNConfig serverName serverCfg) != null)
          cfg.openvpn.servers);
  };
}
