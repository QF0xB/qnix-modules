{
  lib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/server.nix { inherit lib; };
in
{
  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
