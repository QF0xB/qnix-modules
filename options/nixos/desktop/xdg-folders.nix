{ lib, ... }:
{
  options.qnix.desktop.xdg-folders = {
    enable = lib.mkEnableOption "XDG user folders" // {
      default = false;
    };
  };
}
