{ lib, ... }:
let
  sharedQnix = import ../shared/desktop.nix { inherit lib; };
in
{
  imports = [
    ./workstation.nix
  ]
  ++ (lib.qnix.mkNixosFeatureImports {
    category = "desktop";
    name = "browser";
  })
  ++ (lib.qnix.mkNixosOptionImports {
    category = "desktop";
    name = "file-manager";
  })
  ++ (lib.qnix.mkNixosOptionImports {
    category = "desktop";
    name = "lock";
  })
  ++ (lib.qnix.mkNixosFeatureImports {
    category = "desktop";
    name = "terminal";
  })
  ++ (lib.qnix.mkNixosFeatureImports {
    category = "desktop";
    name = "xdg-folders";
  })
  ++ (lib.qnix.mkNixosFeatureImports {
      category = "security";
      name = "polkit";
    });

  config = {
    qnix = lib.recursiveUpdate sharedQnix {
      security.polkit.enable = lib.mkDefault true;

      system.packages.nerdFonts.enable = lib.mkDefault true;

      network.networkmanager = {
        enable = lib.mkDefault true;
        gui = lib.mkDefault true;
      };
    };
  };
}
