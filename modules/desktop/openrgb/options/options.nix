{ lib, ... }:

{
  options.qnix.desktop.openrgb = {
    enable = lib.mkEnableOption "openrgb" // {
      default = false;
    };
  };
}
