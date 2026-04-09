{ lib, ... }:
let
  sharedQnix = import ../shared/desktop.nix { inherit lib; };
in
{
  imports = [ ./workstation.nix ];

  config = {
    qnix = lib.recursiveUpdate sharedQnix {
      system.packages.nerdFonts.enable = lib.mkDefault true;

      network.networkmanager = {
        enable = lib.mkDefault true;
        gui = lib.mkDefault true;
      };
    };
  };
}
