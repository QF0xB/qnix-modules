{ lib, ... }:

{
  options.qnix.desktop.periphery = {
    enable = lib.mkEnableOption "periphery" // {
      default = false;
    };
  };
}
