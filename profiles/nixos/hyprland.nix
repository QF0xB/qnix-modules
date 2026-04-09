{ lib, ... }:
let
  sharedQnix = import ../shared/hyprland.nix { inherit lib; };
in
{
  imports = [
    ./wayland.nix
  ] ++ (lib.qnix.mkNixosFeatureImports {
    category = "desktop";
    name = "hyprland";
  });

  config = {
    qnix = lib.recursiveUpdate sharedQnix { };
  };
}
