{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.system.power-management;
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
  tunedProfile =
    {
      quiet = "qnix-quiet";
      powersave = "powersave";
      balanced = "balanced";
      performance = "performance";
      full-power = "throughput-performance";
    }
    .${cfg.tuned.profile};
in
{
  config = lib.mkIf (cfg.enable && config.qnix.status.laptop) {
    services.tuned = lib.mkIf cfg.tuned.enable {
      enable = true;
      ppdSupport = true;
      profiles."qnix-quiet" = qnixQuietProfile;
      ppdSettings.main.default = tunedProfile;
    };

    services.tlp.enable = !cfg.tuned.enable;
    services.upower.enable = cfg.upower.enable;

    powerManagement.enable = true;

    qnix.persist.root.files = [
      "/etc/tuned/active_profile"
    ];
  };
}
