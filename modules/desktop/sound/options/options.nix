{ lib, ... }:

{
  options.qnix.desktop.sound = {
    enable = lib.mkEnableOption "sound" // {
      default = true;
    };

    gui.enable = lib.mkEnableOption "GUI sound applications" // {
      default = true;
    };
  };
}
