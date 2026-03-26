{ lib, ... }:

{
  options.qnix.core.microcontroller = {
    enable = lib.mkEnableOption "microcontroller" // {
      default = false;
    };
  };
}
