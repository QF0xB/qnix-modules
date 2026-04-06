{ lib, config, ... }:
{
  imports = [
    ../../modules/nixos/security/openssh.nix
  ];

  config = {
    qnix = {
      status = {
        headless = lib.mkDefault true;
        server = lib.mkDefault true;
      };

      security = {
        fail2ban.enable = lib.mkDefault true;
        openssh.enable = lib.mkDefault true;
      };
    };
  };
}
