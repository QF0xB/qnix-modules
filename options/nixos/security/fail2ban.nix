{ lib, ... }:
{
  options.qnix.security.fail2ban = {
    enable = lib.mkEnableOption "fail2ban";

    bantime = lib.mkOption {
      type = lib.types.str;
      default = "600";
      description = "The time in seconds to ban an IP address for.";
    };

    bantimeIncrement = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to increment the ban time.";
    };
  };
}
