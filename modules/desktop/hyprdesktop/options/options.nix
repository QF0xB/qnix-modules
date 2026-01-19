{ lib, ... }:

{
  imports = [
    ./hyprsuite/options.nix
  ];

  options.qnix.desktop.hyprdesktop = {
    enable = lib.mkEnableOption "hyprdesktop" // {
      default = false;
    };
  };
}
