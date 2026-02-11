{ lib, ... }:

{
  options.qnix.desktop.tidal-hifi = {
    enable = lib.mkEnableOption "tidal-hifi" // {
      default = false;
    };
  };
}
