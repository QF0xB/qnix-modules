{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/nvf.nix { inherit lib; };
in
{
  imports = qnixLib.qnix.mkHomeFeatureImports {
    category = "dev";
    name = "nvf";
  };

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
