{ lib, config, ... }:
{
  imports = [
    ./base.nix
  ];

  config = {
    qnix.system.headless = lib.mkDefault true;

    services.openssh.enable = lib.mkDefault true;
    services.fail2ban.enable = lib.mkDefault true;
  };
}
