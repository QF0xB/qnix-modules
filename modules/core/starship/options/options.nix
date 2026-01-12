{ lib, ... }:

{
  options.qnix.core.starship = {
    enable = lib.mkEnableOption "starship" // {
      default = true;
    };
  };
}
