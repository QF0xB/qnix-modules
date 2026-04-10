{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.network.addressing;

  renderedInterfaces = lib.mapAttrs (
    _: interfaceCfg:
    lib.optionalAttrs (interfaceCfg.useDHCP != null) {
      useDHCP = interfaceCfg.useDHCP;
    }
    // lib.optionalAttrs (interfaceCfg.ipv4.addresses != [ ]) {
      ipv4.addresses = interfaceCfg.ipv4.addresses;
    }
    // lib.optionalAttrs (interfaceCfg.ipv6.addresses != [ ]) {
      ipv6.addresses = interfaceCfg.ipv6.addresses;
    }
  ) cfg.interfaces;

  hasAddressing =
    cfg.hostName != null
    || cfg.nameservers != [ ]
    || cfg.defaultGateway != null
    || cfg.defaultGateway6 != null
    || renderedInterfaces != { };
in
{
  config = lib.mkIf hasAddressing {
    networking =
      {
        useDHCP = lib.mkDefault false;
      }
      // lib.optionalAttrs (cfg.hostName != null) {
        hostName = cfg.hostName;
      }
      // lib.optionalAttrs (cfg.nameservers != [ ]) {
        nameservers = cfg.nameservers;
      }
      // lib.optionalAttrs (cfg.defaultGateway != null) {
        defaultGateway =
          {
            address = cfg.defaultGateway;
          }
          // lib.optionalAttrs (cfg.defaultGatewayInterface != null) {
            interface = cfg.defaultGatewayInterface;
          };
      }
      // lib.optionalAttrs (cfg.defaultGateway6 != null) {
        defaultGateway6 =
          {
            address = cfg.defaultGateway6;
          }
          // lib.optionalAttrs (cfg.defaultGateway6Interface != null) {
            interface = cfg.defaultGateway6Interface;
          };
      }
      // lib.optionalAttrs (renderedInterfaces != { }) {
        interfaces = renderedInterfaces;
      };
  };
}
