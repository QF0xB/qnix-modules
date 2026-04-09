{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/stylix.nix { inherit lib; };
in
{
  imports = qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "stylix";
  };

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
