{ lib, ... }:
let
  sharedQnix = import ../shared/personal.nix { inherit lib; };
in
{
  imports =
    (lib.qnix.mkNixosOptionImports {
      category = "desktop";
      name = "notes";
    })
    ++ (lib.qnix.mkNixosOptionImports {
      category = "desktop";
      name = "bitwarden";
    })
    ++ (lib.qnix.mkNixosOptionImports {
      category = "desktop";
      name = "music";
    });

  config.qnix = sharedQnix;
}
