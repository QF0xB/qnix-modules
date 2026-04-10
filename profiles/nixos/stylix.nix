{ lib, ... }:
let
  sharedQnix = import ../shared/stylix.nix { inherit lib; };
in
{
  imports = lib.qnix.mkNixosFeatureImports {
    category = "desktop";
    name = "stylix";
  };

  config = {
    qnix = lib.recursiveUpdate sharedQnix { };
  };
}
