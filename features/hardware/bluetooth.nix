{
  environments = [ "nixos" ];

  options =
    {
      context,
      isGraphical,
      lib,
      ...
    }:
    {
      gui = lib.mkOption {
        type = lib.types.bool;
        default = isGraphical;
        description = "Whether to enable the Blueman graphical Bluetooth manager.";
      };

      powerOnBoot = lib.mkOption {
        type = lib.types.bool;
        default = !(context.laptop or false);
        description = "Whether Bluetooth should be powered on during boot; disabled by default on laptops.";
      };

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Additional BlueZ configuration settings.";
      };
    };

  nixos =
    {
      cfg,
      ...
    }:
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = cfg.powerOnBoot;
        settings = cfg.settings;
      };

      services.blueman.enable = cfg.gui;
    };
}
