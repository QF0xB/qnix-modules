{ lib, config, ... }:

{
  imports = lib.qnix.mkNixosFeatureImports {
    category = "storage";
    name = "impermanence";
  };

  config = {
    qnix = {
      storage = {
        impermanence.enable = lib.mkDefault true;
      };
    };
  };
}
