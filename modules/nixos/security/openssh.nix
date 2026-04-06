{ lib, config, ... }:

let
  cfg = config.qnix.security.openssh;
in
{
  options = {
    qnix = {
      security.openssh = {
        ports = lib.mkOption {
          type = lib.types.listOf lib.types.int;
          default = [ 22 ];
          description = "The ports on which to listen for SSH connections.";
        };
      };
    };
  };

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
