{ lib, ... }:

{
  options.qnix.desktop.obsidian = {
    enable = lib.mkEnableOption "obsidian" // {
      default = false;
    };
  };
}
