{
  environments = [
    "nixos"
  ];

  options =
    { lib, ... }:
    {
      scrub = {
        enable = lib.mkEnableOption "zfs auto-scrub" // {
          default = true;
        };

        interval = lib.mkOption {
          type = lib.types.str;
          default = "daily";
          description = "The interval at which to scrub the ZFS pool.";
        };
      };

      trim = {
        enable = lib.mkEnableOption "zfs trim" // {
          default = true;
        };

        interval = lib.mkOption {
          type = lib.types.str;
          default = "daily";
          description = "The interval at which to trim the ZFS pool.";
        };
      };

      impermanenceReset = {
        enable = lib.mkEnableOption "ZFS impermanence rollback" // {
          default = true;
        };

        dataset = lib.mkOption {
          type = lib.types.str;
          default = "zroot/root";
          description = "ZFS dataset rolled back before the impermanent root is mounted.";
        };

        snapshot = lib.mkOption {
          type = lib.types.str;
          default = "blank";
          description = "Snapshot used as the clean impermanence root.";
        };
      };
    };

  nixos =
    {
      cfg,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      impermanenceEnabled = lib.attrByPath [ "qnix" "storage" "impermanence" "enable" ] false config;
    in
    {
      services.zfs = {
        autoScrub.enable = cfg.scrub.enable;
        autoScrub.interval = cfg.scrub.interval;
        trim.enable = cfg.trim.enable;
        trim.interval = cfg.trim.interval;
      };

      boot.initrd.systemd.services.qnix-impermanence-reset =
        lib.mkIf (impermanenceEnabled && cfg.impermanenceReset.enable)
          {
            description = "Reset the impermanent ZFS root dataset";
            wantedBy = [ "initrd.target" ];
            after = [
              "zfs-import.target"
              "systemd-cryptsetup@cryptroot.service"
            ];
            before = [ "sysroot.mount" ];

            path = [ pkgs.zfs ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig = {
              Type = "oneshot";
              StandardOutput = "journal+console";
              StandardError = "journal+console";
            };

            script = ''
              zfs rollback -r ${cfg.impermanenceReset.dataset}@${cfg.impermanenceReset.snapshot}
            '';
          };
    };
}
