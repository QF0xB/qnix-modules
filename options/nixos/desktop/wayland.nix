{ lib, ... }:
{
  options.qnix.desktop.wayland = {
    enable = lib.mkEnableOption "Wayland compositor session support";
  };
}
