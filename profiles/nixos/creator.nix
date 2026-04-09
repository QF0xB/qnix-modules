{ lib, ... }:
let
  sharedQnix = import ../shared/creator.nix { inherit lib; };
in
{
  imports = lib.qnix.mkNixosOptionImports {
    category = "desktop";
    name = "obs";
  };

  config.qnix = sharedQnix;
}
