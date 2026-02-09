{ lib, ... }:

{
  options.qnix.desktop.periphery = {
    thunderbolt = {
      enable = lib.mkEnableOption "thunderbolt" // {
        default = true;
      };
    };
  };
}
