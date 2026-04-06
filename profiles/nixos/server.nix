{ lib, config, ... }:
{
  imports = [
    ../../modules/nixos/security/openssh.nix
    ../../modules/nixos/security/fail2ban.nix
  ];

  config = {
    qnix.status.headless = lib.mkDefault false;
    qnix.status.server = lib.mkDefault true;

  };
}
