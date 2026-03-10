{ lib, config, ... }:

let
  cfg = config.qnix.core.virtualisation.virt-manager;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation = {
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
    programs.virt-manager.enable = cfg.gui;

    boot.initrd.availableKernelModules = lib.mkIf cfg.passthrough [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    qnix = {
      persist = {
        root = {
          directories = [ "/var/lib/libvirt" ];
          cache.directories = [ "/var/lib/libvirtd" ];
        };
      };

      core.user.defaultExtraGroups = [
        "libvirtd"
        "kvm"
        "plugdev"
        "dialout"
      ];
    };
  };
}
