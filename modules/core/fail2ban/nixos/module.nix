{ lib, config, ... }:

let
  cfg = config.qnix.core.fail2ban;
in
{
  config = lib.mkIf (cfg.enable or config.qnix.ssh-server.enable) {
    services.fail2ban = {
      enable = true;

      banTime = cfg.bantime;

      bantime-increment = {
        enable = cfg.banTimeIncrement;
        factor = 24;
        overalljails = true;
      };
    };
  };
}
