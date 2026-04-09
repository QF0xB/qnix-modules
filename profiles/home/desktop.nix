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
  ] ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "terminal";
  });

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
