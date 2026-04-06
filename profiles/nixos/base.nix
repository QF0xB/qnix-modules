{ lib, config, ... }:
{
  config = {
    time.timeZone = lib.mkDefault "Europe/Berlin";

    nix.settings.experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];
  };
}
