{ lib, config, pkgs, ... }:

let
  cfg = config.qnix.core.vpn;
in
{
  config = lib.mkIf (cfg.enable && cfg.openvpn.enable) {
    # Create /etc/openvpn/<serverName>/... from the files passed in via options.
    #
    # We support two modes:
    # - `files.<path>.content`: embedded Nix content -> written via `environment.etc` (Nix store)
    # - `files.<path>.source`: absolute path on the target machine -> copied during activation
    environment.etc =
      lib.mkMerge [
        (lib.listToAttrs
          (lib.filter (x: x != null) (
            lib.concatLists
              (lib.mapAttrsToList
                (serverName: serverCfg:
                  lib.mapAttrsToList
                    (filePath: fileCfg:
                      if fileCfg.content != null then {
                        name = "openvpn/${serverName}/${filePath}";
                        value = {
                          source = pkgs.writeText
                            "openvpn-${serverName}-${lib.replaceStrings ["/"] ["-"] filePath}"
                            fileCfg.content;
                          mode = fileCfg.mode;
                        };
                      } else null)
                    serverCfg.files)
                cfg.openvpn.servers
              )
          )))
      ];

    # Copy files specified via `files.<path>.source` during activation.
    system.activationScripts.openvpnInstallFiles = lib.mkAfter (
      let
        installLines =
          lib.filter (x: x != null) (
            lib.concatLists
              (lib.mapAttrsToList
                (serverName: serverCfg:
                  lib.mapAttrsToList
                    (filePath: fileCfg:
                      if fileCfg.source != null then
                        "install -D -m ${fileCfg.mode} \"${fileCfg.source}\" \"/etc/openvpn/${serverName}/${filePath}\""
                      else
                        null)
                    serverCfg.files)
                cfg.openvpn.servers
              )
          );
      in
      ''
        set -eu
        ${lib.concatStringsSep "\n" installLines}
      ''
    );

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
        (serverName: serverCfg:
          let
            baseConfig = mkOpenVPNConfig serverName serverCfg;
            finalConfig =
              if serverCfg.authUserPassFile != null then
                "${baseConfig}\nauth-user-pass ${serverCfg.authUserPassFile}\n"
              else
                baseConfig;
          in
          {
          config = finalConfig;
          updateResolvConf = serverCfg.updateResolvConf;
          up = serverCfg.up;
          down = serverCfg.down;
          autoStart = serverCfg.autoStart;
          # Prefer file-based auth to avoid embedding secrets in the Nix store.
          authUserPass =
            if serverCfg.authUserPassFile != null then
              null
            else
              serverCfg.authUserPass;
        })
        (lib.filterAttrs
          (serverName: serverCfg: (mkOpenVPNConfig serverName serverCfg) != null)
          cfg.openvpn.servers);

    # systemd integration: upstream sets Type=notify; override to avoid startup
    # timeouts when OpenVPN doesn't send sd_notify.
    systemd.services =
      lib.mkMerge [
        (lib.listToAttrs
          (lib.mapAttrsToList
            (serverName: serverCfg: {
              name = "openvpn-${serverName}";
              value = {
                serviceConfig.Type = lib.mkForce serverCfg.systemdServiceType;
              };
            })
            cfg.openvpn.servers))
      ];
  };
}
