{ lib, ... }:
{
  options.qnix.desktop.noctalia = {
    enable = lib.mkEnableOption "noctalia" // {
      default = false;
    };
  };
}
