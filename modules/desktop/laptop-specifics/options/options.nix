{ lib, ... }:

let
  profileType = lib.types.enum [
    "quiet" # As quiet as possible (maps to Tuned powersave)
    "powersave"
    "balanced"
    "performance"
    "full-power" # Max throughput (maps to Tuned throughput-performance)
  ];
in
{
  options.qnix.desktop.laptop-specifics = {
    enable = lib.mkEnableOption "laptop-specific services (Tuned, upower)" // {
      default = true;
    };

    tuned = {
      enable =
        lib.mkEnableOption "TuneD for power/performance profiles (replaces power-profiles-daemon)"
        // {
          default = true;
        };

      profile = lib.mkOption {
        type = profileType;
        default = "balanced";
        description = ''
          Default TuneD profile. quiet = custom profile stricter than powersave (CPU cap + power hints);
          full-power = maximum throughput (throughput-performance).
        '';
      };

      # Only used when profile = "quiet"
      quietMaxPerfPct = lib.mkOption {
        type = lib.types.ints.between 10 100;
        default = 70;
        description = ''
          When using the quiet profile, cap CPU at this percentage of max frequency (Intel P-State / AMD).
          Lower = cooler/quieter, higher = more headroom (e.g. 50 = very quiet, 70 = balanced quiet).
        '';
      };
    };

    upower =
      lib.mkEnableOption "upower (battery/power info; required by TuneD when using PPD compatibility)"
      // {
        default = true;
      };
  };
}
