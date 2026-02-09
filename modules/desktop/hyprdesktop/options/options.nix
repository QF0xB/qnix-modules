{ lib, ... }:

{
  imports = [
    ./hyprsuite/options.nix
    ./ags.nix
    ./noctalia.nix
  ];

  options.qnix.desktop.hyprdesktop = {
    enable = lib.mkEnableOption "hyprdesktop" // {
      default = false;
    };
  };
}
