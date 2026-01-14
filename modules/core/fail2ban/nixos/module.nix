{ lib, config, ... }:

let
  cfg = config.qnix.core.fail2ban;
in
{
  config = lib.mkIf (cfg.enable || config.qnix.core.ssh-server.enable) {
    services.fail2ban = {
      enable = true;

      bantime = cfg.banTime;

      bantime-increment = {
        enable = cfg.banTimeIncrement;
        factor = "24";
        overalljails = true;
      };
    };
  };
}
