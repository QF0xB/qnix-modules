{ lib, ... }:

{
  options.qnix.boot = {
    enable = lib.mkEnableOption "boot" // {
      default = false;
    };
  };
}
