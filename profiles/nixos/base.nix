{ lib, config, ... }:
{
  imports = [
    ../../modules/nixos/system/boot.nix
    ../../modules/nixos/system/localisation.nix
    ../../modules/nixos/system/packages.nix
    ../../modules/nixos/system/users.nix
  ];

  config = {
    qnix = {
      system = {
        boot-manager.enable = lib.mkDefault true;
        localisation.enable = lib.mkDefault true;
        packages.enable = lib.mkDefault true;
        users = {
          enable = lib.mkDefault true;
          defaultExtraGroups = lib.mkDefault [ "wheel" ];
          root = {
            enable = lib.mkDefault false;
          };
        };
      };
    };

    nix.settings.experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];
  };
}
