{ lib, config, ... }:

let
  # Options can be in NixOS (system-wide, if loadOptions=true) or home-manager (via config.hm.qnix.*)
  # Check system-wide first, fallback to home-manager for flexibility (e.g., servers without home-manager)
  cfg = config.qnix.core.boot or config.hm.qnix.core.boot;
in
{
  config = {
    boot = {
      supportedFilesystems = {
        zfs = cfg.zfsSupport;
        ext4 = true;
      };

      loader = {
        efi = lib.mkIf cfg.efiSupport {
          efiSysMountPoint = "/boot";
          canTouchEfiVariables = true;
        };
      };

      initrd = lib.mkIf cfg.encrypted {
        luks.devices.cryptroot = {
          preLVM = true;
          crypttabExtraOpts = [ "fido-device=auto" ];
        };
        systemd.enable = true;
        # Add ZFS support to initrd so it can import after LUKS unlock
        availableKernelModules = [ "zfs" ];
      };

      # ZFS configuration - don't force import, wait for LUKS device
      zfs.forceImportRoot = false;

      loader.timeout = cfg.timeout;
    };
  };
}

