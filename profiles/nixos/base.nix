{ lib, config, ... }:
{
  imports = [
    ../../modules/nixos/system/boot.nix
  ];

  config = {
    qnix = {
      system = {
        boot-manager.enable = lib.mkDefault true;
      };
    };

    time.timeZone = lib.mkDefault "Europe/Berlin";

    nix.settings.experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];
  };
}
