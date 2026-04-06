{ lib, config, ... }:
{
  imports = [
    ./base.nix
  ];

  config = {
    qnix.profiles.base.enable = true;

    qnix.system.headless = lib.mkDefault false;
  };
}
