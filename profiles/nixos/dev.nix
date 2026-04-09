{ lib, ... }:
let
  sharedQnix = import ../shared/dev.nix { inherit lib; };
in
{
  imports = lib.concatLists [
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "direnv";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "git";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "dev";
      name = "devenv";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "dev";
      name = "nixfmt";
    })
  ];

  config = {
    qnix = lib.recursiveUpdate sharedQnix {
      dev = {
        devenv.enable = lib.mkDefault true;
        nixfmt.enable = lib.mkDefault true;
      };
    };
  };
}
