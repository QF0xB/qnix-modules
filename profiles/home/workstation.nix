{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/workstation.nix { inherit lib; };
in

{
  imports = lib.concatLists [
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "dev";
      name = "git";
    })
    (qnixLib.qnix.mkHomeOptionImports {
      category = "system";
      name = "packages";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "security";
      name = "gpg";
    })
  ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
