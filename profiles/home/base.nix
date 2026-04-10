{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/base.nix { inherit lib; };
in
{
  imports = lib.concatLists [
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "system";
      name = "shell";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "system";
      name = "starship";
    })
  ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
