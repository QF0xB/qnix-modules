{ lib, ... }:
let
  sharedQnix = import ../shared/hyprland.nix { };
in
{
  imports = [ ./wayland.nix ];

  config = {
    qnix = lib.recursiveUpdate sharedQnix { };
  };
}
