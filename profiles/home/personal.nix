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
      category = "desktop";
      name = "notes";
    })
    ++ (qnixLib.qnix.mkHomeFeatureImports {
      category = "desktop";
      name = "bitwarden";
    })
    ++ (qnixLib.qnix.mkHomeFeatureImports {
      category = "desktop";
      name = "music";
    });

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
