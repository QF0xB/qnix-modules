{ lib, config, ... }:
let
  cfg = config.qnix.security.fail2ban;
in
{
  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      bantime = cfg.bantime;
      bantime-increment = {
        enable = cfg.bantimeIncrement;
        factor = "24";
        overalljails = true;
      };
    };
  };
}
