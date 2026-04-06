{ lib, config, ... }:
{
  config = lib.mkIf config.qnix.profiles.base.enable {
    time.timeZone = lib.mkDefault "Europe/Berlin";

    nix.settings.experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];
  };
}
