{ lib, ... }:
let
  sharedQnix = import ../shared/wayland.nix { inherit lib; };
in
{
  imports = [
    ./desktop.nix
  ] ++ (lib.qnix.mkNixosFeatureImports {
    category = "desktop";
    name = "wayland";
  });

  config = {
    qnix = lib.recursiveUpdate sharedQnix { };
  };
}
