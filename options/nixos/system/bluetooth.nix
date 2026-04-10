{ lib, ... }:

{
  options.qnix.system.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";

    powerOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether Bluetooth adapters should be powered on at boot.";
    };

    manager.enable = lib.mkEnableOption "Blueman Bluetooth manager" // {
      default = true;
    };
  };
}
