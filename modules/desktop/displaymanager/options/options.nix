{ lib, ... }:

{
  imports = [
    ./sddm-options.nix
  ];

  options.qnix.desktop.displaymanager = {
    enable = lib.mkEnableOption "displaymanager" // {
      default = true;
    };
  };
}
