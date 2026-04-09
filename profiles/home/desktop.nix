{
  lib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/desktop.nix { inherit lib; };
in
{
  imports = [ ./workstation.nix ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
