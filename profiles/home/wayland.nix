{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/wayland.nix { inherit lib; };
in
{
  imports = [
    ./desktop.nix
  ] ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "wayland";
  });

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
