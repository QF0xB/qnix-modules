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
    category = "desktop";
    name = "terminal";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "xdg-folders";
  });

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
