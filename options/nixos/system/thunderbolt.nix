{ lib, ... }:

{
  options.qnix.system.thunderbolt = {
    enable = lib.mkEnableOption "Thunderbolt support";
  };
}
