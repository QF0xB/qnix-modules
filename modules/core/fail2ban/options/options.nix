{ lib, ... }:

{
  options.qnix.core.fail2ban = {
    enable = lib.mkEnableOption "fail2ban" // {
      default = false;
    };

    banTime = lib.mkOption {
      type = lib.types.str;
      default = "1h";
      description = "Time to ban for";
    };

    banTimeIncrement = lib.mkEnableOption "fail2ban ban time increment" // {
      default = true;
    };
  };
}
