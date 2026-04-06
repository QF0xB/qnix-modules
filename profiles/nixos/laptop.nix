{ lib, config, ... }:
{
  imports = [
    ./workstation.nix
  ];

  config = lib.mkIf config.qnix.profiles.laptop.enable {
    qnix.profiles.workstation.enable = true;
  };
}
