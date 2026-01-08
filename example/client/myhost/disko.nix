{ lib, ... }:

let
  disk = builtins.getEnv "DISK";
  swapSize = builtins.getEnv "SWAP_SIZE";     # e.g. "16G" or "0"/unset
  haveSwap = swapSize != "" && swapSize != "0";
  halfSize = (builtins.getEnv "HALF_SIZE") == "1";

  encrypt = (builtins.getEnv "ENCRYPT") == "1"; # set by installer script
in
{
  assertions = [{
    assertion = disk != "";
    message = "Set DISK=/dev/<disk> when running disko.";
  }];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = disk;

      content = {
        type = "gpt";
        partitions =
          {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
          }
          // lib.optionalAttrs haveSwap {
            swap = {
              size = swapSize;
              type = "8200";
              content = { type = "swap"; };
            };
          }
          // {
            # Single “root” partition that is either:
            # - plain ZFS vdev (ENCRYPT=0)
            # - LUKS container containing ZFS vdev (ENCRYPT=1)
            root = {
              size = if halfSize then "50%" else "100%";
              type = if encrypt then "8309" else "BF01"; # cosmetic GPT type

              content =
                if encrypt then {
                  type = "luks";
                  name = "cryptroot"; # /dev/mapper/cryptroot
                  content = {
                    type = "zfs";
                    pool = "zroot";
                  };
                } else {
                  type = "zfs";
                  pool = "zroot";
                };
            };
          };
      };
    };

    zpool.zroot = {
      type = "zpool";

      options = {
        ashift = "12";
        autotrim = "on";
      };

      rootFsOptions = {
        compression = "zstd";
        acltype = "posixacl";
        atime = "off";
        xattr = "sa";
        normalization = "formD";
      };

      # “Ephemeral /” via rollback: keep / as its own dataset
      datasets = {
        root = { type = "zfs_fs"; mountpoint = "/"; };
        persist = { type = "zfs_fs"; mountpoint = "/persist"; };
        nix = { type = "zfs_fs"; mountpoint = "/nix"; };
        cache = { type = "zfs_fs"; mountpoint = "/cache"; };
      };
    };
  };
}
