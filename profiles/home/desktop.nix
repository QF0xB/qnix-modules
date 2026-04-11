{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/desktop.nix { inherit lib; };
in
{
  imports = [
    ./workstation.nix
  ]
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "apps";
    name = "browser";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "clipboard";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "apps";
    name = "file-manager";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "lock";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "screenshots";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "sound";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "terminal";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "xdg-folders";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "client-pr-notify";
  });

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
