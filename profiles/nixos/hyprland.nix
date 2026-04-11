{ lib, ... }:
let
  sharedQnix = import ../shared/hyprland.nix { inherit lib; };
in
{
  imports = [
    ./wayland.nix
  ]
  ++ (lib.qnix.mkNixosOptionImports {
    category = "desktop";
    name = "client-pr-notify";
  })
  ++ (lib.qnix.mkNixosFeatureImports {
    category = "security";
    name = "gnome-keyring";
  })
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
      security.gnome-keyring.enable = lib.mkDefault true;
    };
  };
}
