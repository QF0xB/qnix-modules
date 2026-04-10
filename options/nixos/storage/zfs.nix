{ lib, ... }:
{
  options.qnix.storage.zfs = {
    enable = lib.mkEnableOption "zfs";

    scrub = {
      enable = lib.mkEnableOption "zfs scrub" // {
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
  };
}
