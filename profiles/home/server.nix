{
  lib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/server.nix { inherit lib; };
in
{
  imports = [ ./base.nix ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
