{
  lib,
  config,
  ...
}:

let
  cfg = config.qnix.system.plymouth;
in
{
  config = lib.mkIf cfg.enable {
    stylix.targets.plymouth.enable = false;

    boot = {
      plymouth = {
        enable = true;
        theme = cfg.theme;
        themePackages = [ cfg.themePackage ];
      };
    }
    // lib.optionalAttrs cfg.quietBoot {
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
