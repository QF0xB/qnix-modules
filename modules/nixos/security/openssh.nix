{ lib, config, ... }:

let
  cfg = config.qnix.security.openssh;
in
{
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = cfg.ports;
      openFirewall = true;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };
}
