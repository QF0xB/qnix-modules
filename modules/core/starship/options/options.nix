{ lib, ... }:

{
  options.qnix.core.starship = {
    enable = lib.mkEnableOption "starship" // {
      default = true;
    };

    qnixFormat = lib.mkEnableOption "qnix format" // {
      default = true;
    };
  };
}
