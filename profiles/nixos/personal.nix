{ lib, ... }:
let
  sharedQnix = import ../shared/personal.nix { inherit lib; };
in
{
  imports =
    (lib.qnix.mkNixosFeatureImports {
      category = "desktop";
      name = "notes";
    })
    ++ (lib.qnix.mkNixosFeatureImports {
      category = "desktop";
      name = "bitwarden";
    })
    ++ (lib.qnix.mkNixosFeatureImports {
      category = "desktop";
      name = "music";
    });

  config.qnix = sharedQnix;
}
