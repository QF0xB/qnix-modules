{ lib, ... }:
let
  sharedQnix = import ../shared/hyprland.nix { inherit lib; };
in
{
  imports = [
    ./wayland.nix
  ]
  ++ (lib.qnix.mkNixosFeatureImports {
    category = "desktop";
    name = "displaymanager";
  })
  ++ (lib.qnix.mkNixosFeatureImports {
    category = "desktop";
    name = "noctalia";
  })
  ++ (lib.qnix.mkNixosFeatureImports {
    category = "hyprland";
    name = "hyprland";
  });

  config = {
    qnix = lib.recursiveUpdate sharedQnix {
      desktop.displaymanager = {
        enable = lib.mkDefault true;
        sddm.enable = lib.mkDefault true;
      };
      desktop.noctalia.enable = lib.mkDefault true;
    };
  };
}
