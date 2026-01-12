{ lib, ... }:

{
  options.qnix.core.lsd = {
    enable = lib.mkEnableOption "lsd" // {
      default = false;
    };
  };
}
