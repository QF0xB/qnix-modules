{ lib, ... }:
let
  sharedQnix = import ../shared/laptop.nix { inherit lib; };
in
{
  imports = [
    ./workstation.nix
  ]
  ++ (lib.qnix.mkNixosFeatureImports {
    category = "system";
    name = "power-management";
  });

  config = {
    qnix = lib.recursiveUpdate sharedQnix {
      system.power-management = {
        enable = lib.mkDefault true;
        tuned.enable = lib.mkDefault true;
        upower.enable = lib.mkDefault true;
      };
    };
  };
}
