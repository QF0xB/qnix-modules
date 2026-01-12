{ lib, ... }:

{
  options.qnix.core.fish = {
    enable = lib.mkEnableOption "fish" // {
      default = true;
    };

    defaultShell = lib.mkEnableOption "default shell" // {
      default = true;
    };
  };
}
