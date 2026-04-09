{ lib, ... }:
let
  sharedQnix = import ../shared/wayland.nix { };
in
{
  imports = [ ./desktop.nix ];

  config = {
    qnix = lib.recursiveUpdate sharedQnix { };
  };
}
