{ lib, ... }:

{
  options.qnix.core.plymouth = {
    enable = lib.mkEnableOption "plymouth" // {
      default = true;
    };
  };
}
