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
      name = "codex";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "dev";
      name = "cursor";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "dev";
      name = "direnv";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "dev";
      name = "git";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "dev";
      name = "jetbrains";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "dev";
      name = "postman";
    })
  ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
