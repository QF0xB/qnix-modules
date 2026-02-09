{ lib, ... }:

{
  options.qnix.desktop.hyprdesktop.noctalia = {
    enable = lib.mkEnableOption "noctalia" // {
      default = false;
    };
  };
}
