{ lib, config, ... }:
{
  imports = [
    ./base.nix
  ];

  config = lib.mkIf config.qnix.profiles.workstation.enable {
    qnix.profiles.base.enable = true;

    qnix.system.headless = lib.mkDefault false;
  };
}
