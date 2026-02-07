{ lib, ... }:

{
  imports = [
    ./hyprsuite/options.nix
    ./ags.nix
    ./dms.nix
  ];

  options.qnix.desktop.hyprdesktop = {
    enable = lib.mkEnableOption "hyprdesktop" // {
      default = false;
    };
  };
}
