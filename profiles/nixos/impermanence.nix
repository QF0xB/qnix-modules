{ lib, config, ... }:

{
  imports = [
    ../../modules/nixos/storage/impermanence.nix
  ];

  config = {
    qnix = {
      storage = {
        impermanence.enable = lib.mkDefault true;
      };
    };
  };
}
