{ lib, ... }:

{
  options.qnix.core.zfs = {
    enable = lib.mkEnableOption "zfs" // {
      default = true;
    };

    scrub = {
      enable = lib.mkEnableOption "zfs scrub" // {
        default = true;
      };

      interval = lib.mkOption {
        type = lib.types.int;
        default = 12;
        description = "Interval for ZFS scrub";
      };
    };
  };
}
