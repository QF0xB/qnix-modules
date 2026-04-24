{ lib, config, ... }:
let
  cfg = config.qnix.network.coredns;

  generatedCorefile = ''
    .:53 {
      errors
      log
      health
      forward . ${lib.concatStringsSep " " cfg.forwardUpstreams}
      cache 300
    }
  '';

  corefileText = if cfg.corefile != null then cfg.corefile else generatedCorefile;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = (cfg.corefile != null) || (cfg.forwardUpstreams != [ ]);
          message = "qnix.network.coredns.forwardUpstreams must be non-empty when corefile is null.";
        }
      ];

      services.coredns = {
        enable = true;
        inherit (cfg) package extraArgs;
        config = corefileText;
      };
    })

    (lib.mkIf (cfg.enable && cfg.openFirewall) {
      qnix.network.firewall = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    })
  ];
}
