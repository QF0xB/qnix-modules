{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.system.laptop;
in
{
  config = lib.mkIf (cfg.enable && config.qnix.status.laptop) {
    services.thermald.enable = cfg.thermald.enable;
    services.fwupd.enable = cfg.fwupd.enable;

    services.logind = lib.mkIf cfg.lid.enable {
      settings.Login = {
        HandleLidSwitch = cfg.lid.whenClosed;
        HandleLidSwitchExternalPower = cfg.lid.whenClosedExternalPower;
        HandleLidSwitchDocked = cfg.lid.whenClosedDocked;
      };
    };
  };
}
