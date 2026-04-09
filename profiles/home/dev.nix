{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/dev.nix { inherit lib; };
in
{
  imports = lib.concatLists [
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "dev";
      name = "direnv";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "dev";
      name = "git";
    })
  ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
