{
  lib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/laptop.nix { inherit lib; };
in
{
  imports = [
    ./workstation.nix
  ];

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
