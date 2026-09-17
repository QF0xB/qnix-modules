{
  environments = [ "nixos" ];

  requires.nixos = [ "hardware.laptop" ];

  options =
    { lib, ... }:
    {
      upower = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable UPower for battery and power-device information.";
      };

      powerProfilesDaemon = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable power-profiles-daemon for power profile switching.";
      };

      cpuFreqGovernor = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "conservative"
            "ondemand"
            "performance"
            "powersave"
            "schedutil"
          ]
        );
        default = null;
        description = "Optional CPU frequency governor.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      ...
    }:
    {
      services.upower.enable = cfg.upower;
      services.power-profiles-daemon.enable = cfg.powerProfilesDaemon;
      powerManagement.cpuFreqGovernor = lib.mkIf (cfg.cpuFreqGovernor != null) cfg.cpuFreqGovernor;
    };
}
