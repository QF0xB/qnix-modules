{ lib, ... }:

{
  options.qnix.core.fish = {
    enable = lib.mkEnableOption "fish" // {
      default = true;
    };

    defaultShell = lib.mkEnableOption "default shell" // {
      default = true;
    };

    aliases = lib.mkEnableOption "aliases" // {
      default = true;
    };

    qnix-aliases = lib.mkEnableOption "aliases for qnix-system" // {
      default = true;
    };
  };
}
