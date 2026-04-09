{ lib, ... }:
let
  sharedQnix = import ../shared/dev.nix { inherit lib; };
in
{
  imports = lib.concatLists [
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "codex";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "dev";
      name = "codex";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "cursor";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "dev";
      name = "cursor";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "direnv";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "git";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "jetbrains";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "dev";
      name = "jetbrains";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "postman";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "dev";
      name = "postman";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "dev";
      name = "wireshark";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "dev";
      name = "wireshark";
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
        wireshark.enable = lib.mkDefault true;
      };
    };
  };
}
