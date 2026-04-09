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
    (qnixLib.qnix.mkHomeOptionImports {
      category = "system";
      name = "packages";
    })
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "security";
      name = "gpg";
    })
  ];

  config = lib.mkMerge [
    (lib.mkIf qnixHomeStandalone {
      qnix = sharedQnix;
    })
  ];
}
