{ lib, ... }:
let
  sharedQnix = import ../shared/personal.nix { inherit lib; };
in
{
  imports =
    (lib.qnix.mkNixosFeatureImports {
      category = "apps";
      name = "notes";
    })
    ++ (lib.qnix.mkNixosFeatureImports {
      category = "apps";
      name = "bitwarden";
    })
    ++ (lib.qnix.mkNixosFeatureImports {
      category = "apps";
      name = "music";
    })
    ++ (lib.qnix.mkNixosFeatureImports {
      category = "apps";
      name = "social";
    });

  config.qnix = sharedQnix;
}
