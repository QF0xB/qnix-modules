{
  lib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/wayland.nix { };
in
{
  imports = [ ./desktop.nix ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
