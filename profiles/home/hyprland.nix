{
  lib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/hyprland.nix { };
in
{
  imports = [ ./wayland.nix ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
