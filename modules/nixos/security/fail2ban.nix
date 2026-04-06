{ lib, config, ... }:
{
  options = {
    qnix = {
      security.fail2ban = {
        bantime = lib.mkOption {
          type = lib.types.int;
          default = 600;
          description = "The time in seconds to ban an IP address for.";
        };

        bantimeIncrement = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to increment the ban time.";
        };
      };
    };
  };

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
