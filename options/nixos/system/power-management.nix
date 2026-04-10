{ lib, ... }:
let
  profileType = lib.types.enum [
    "quiet"
    "powersave"
    "balanced"
    "performance"
    "full-power"
  ];
in
{
  options.qnix.system.power-management = {
    enable = lib.mkEnableOption "laptop power-management services" // {
      default = false;
    };

    tuned = {
      enable = lib.mkEnableOption "TuneD for power and performance profiles" // {
        default = true;
      };

      profile = lib.mkOption {
        type = profileType;
        default = "balanced";
      };

      quietMaxPerfPct = lib.mkOption {
        type = lib.types.ints.between 10 100;
        default = 70;
      };
    };

    upower.enable = lib.mkEnableOption "upower" // {
      default = true;
    };
  };
}
