{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/creator.nix { inherit lib; };
in
{
  imports = qnixLib.qnix.mkHomeFeatureImports {
    category = "apps";
    name = "obs";
  };

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
