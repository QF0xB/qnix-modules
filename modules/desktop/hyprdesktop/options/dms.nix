{ lib, ... }:

{
  options.qnix.desktop.hyprdesktop.dms = {
    enable = lib.mkEnableOption "dms" // {
      default = false;
    };
  };
}
