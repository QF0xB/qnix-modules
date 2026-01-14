{ lib, config, ... }:

let
  cfg = config.qnix.core.ssh-server;
in
{
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;

      ports = [ cfg.port ];
      openFirewall = true;

      settings = {
        PermitRootLogin = if cfg.allowRootLogin then "yes" else "no";
        PasswordAuthentication = cfg.allowPasswordAuthentication;
      };
    };

    programs.ssh.startAgent = cfg.sshAgent;
  };
}
