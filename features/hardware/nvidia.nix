{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      open = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to use NVIDIA's open kernel modules.";
      };

      enable32Bit = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install 32-bit graphics libraries for games and compatibility software.";
      };

      settings = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install the NVIDIA settings application.";
      };

      powerManagement = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable NVIDIA systemd power-management services.";
      };

      driverBranch = lib.mkOption {
        type = lib.types.enum [
          "stable"
          "production"
          "beta"
        ];
        default = "stable";
        description = "NVIDIA driver branch supplied by the active kernel package set.";
      };
    };

  nixos =
    {
      cfg,
      config,
      ...
    }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = cfg.enable32Bit;
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = cfg.open;
        nvidiaSettings = cfg.settings;
        powerManagement.enable = cfg.powerManagement;
        package = config.boot.kernelPackages.nvidiaPackages.${cfg.driverBranch};
      };
    };
}
