{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/hyprland.nix { inherit lib; };
in
{
  imports = [
    ./wayland.nix
  ] ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "hyprland";
  });

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
