{ lib, ... }:

{
  options.qnix.core.fail2ban = {
    enable = lib.mkEnableOption "fail2ban" // {
      default = false;
    };

    banTime = lib.mkOption {
      type = lib.types.int;
      default = 3600;
      description = "Time to ban for, in seconds";
    };

    banTimeIncrement = lib.mkEnableOption "fail2ban ban time increment" // {
      default = true;
    };
  };
}
