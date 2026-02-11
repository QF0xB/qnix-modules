{ lib, ... }:

{
  options.qnix.desktop.xdg-folders = {
    enable = lib.mkEnableOption "xdg-folders" // {
      default = true;
    };
  };
}
