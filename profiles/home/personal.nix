{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/personal.nix { inherit lib; };
in
{
  imports =
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "apps";
      name = "notes";
    })
    ++ (qnixLib.qnix.mkHomeFeatureImports {
      category = "apps";
      name = "bitwarden";
    })
    ++ (qnixLib.qnix.mkHomeFeatureImports {
      category = "apps";
      name = "music";
    });

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
