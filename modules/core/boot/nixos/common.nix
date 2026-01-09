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

      initrd = {
        availableKernelModules = [ "zfs" ];
        systemd.enable = true;
      };

      # initrd = lib.mkIf (!cfg.encrypted) {
      #  luks.devices.cryptroot = {
          # crypttabExtraOpts = lib.mkDefault [ "fido2-device=auto" ];
      #    keyFile = lib.mkForce null;  # force prompt path instead of using keyFile
      #    fallbackToPassword = lib.mkForce true;
      #  };
      #  systemd.enable = true;
        # Add ZFS support to initrd so it can import after LUKS unlock
        # availableKernelModules = [ "zfs" ];
        
        # Configure ZFS import services to wait for LUKS unlock
      #   systemd.services."zfs-import-cache" = {
      #    after = [ "systemd-cryptsetup@cryptroot.service" ];
      #    requires = [ "systemd-cryptsetup@cryptroot.service" ];
      #  };
      #  systemd.services."zfs-import-scan" = {
      #    after = [ "systemd-cryptsetup@cryptroot.service" ];
      #    requires = [ "systemd-cryptsetup@cryptroot.service" ];
      #  };
      #};
      loader.timeout = cfg.timeout;
    };
  };
}

