{ lib, config, ... }:
{
  imports = [
    ./base.nix
  ];

  config = lib.mkIf config.qnix.profiles.server.enable {
    qnix.profiles.base.enable = true;

    qnix.system.headless = lib.mkDefault true;

    services.openssh.enable = lib.mkDefault true;
    services.fail2ban.enable = lib.mkDefault true;
  };
}
