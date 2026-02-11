{
  lib,
  config,
  isLaptop,
  ...
}:

let
  cfg = config.qnix.desktop.laptop-specifics;
  # Custom profile: more conservative than built-in powersave (CPU cap + strict power hints)
  qnixQuietProfile = {
    main = {
      include = "powersave";
      summary = "Quieter than powersave: cap CPU max, strict power hints";
    };
    cpu = {
      type = "cpu";
      governor = "powersave";
      energy_performance_preference = "power";
      energy_perf_bias = "power";
      boost = "0";
      max_perf_pct = toString cfg.tuned.quietMaxPerfPct;
    };
  };
  # Map our profile names to TuneD profile names (qnix-quiet is our custom one)
  tunedProfile =
    name:
    {
      quiet = "qnix-quiet";
      powersave = "powersave";
      balanced = "balanced";
      performance = "performance";
      full-power = "throughput-performance";
    }
    .${name};
in
{
  config = lib.mkIf (isLaptop && cfg.enable) {
    services.tuned = lib.mkIf cfg.tuned.enable {
      enable = true;
      ppdSupport = true;
      # Custom profile for quiet (more conservative than powersave)
      profiles."qnix-quiet" = qnixQuietProfile;
    };

    services.tlp.enable = !cfg.tuned.enable;

    services.upower.enable = cfg.upower;

    qnix.persist.root.files = [
      "/etc/tuned/active_profile"
    ];
  };
}
