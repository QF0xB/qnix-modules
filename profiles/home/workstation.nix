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
    [ ./base.nix ]
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "security";
      name = "gpg";
    })
  ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
