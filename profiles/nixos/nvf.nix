{ lib, ... }:
let
  sharedQnix = import ../shared/nvf.nix { inherit lib; };
in
{
  imports = lib.qnix.mkNixosFeatureImports {
    category = "dev";
    name = "nvf";
  };

  config = {
    qnix = sharedQnix;
  };
}
