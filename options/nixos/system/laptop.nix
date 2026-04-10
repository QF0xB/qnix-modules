{ lib, ... }:
let
  lidActionType = lib.types.enum [
    "ignore"
    "lock"
    "poweroff"
    "reboot"
    "halt"
    "kexec"
    "suspend"
    "hibernate"
    "hybrid-sleep"
    "suspend-then-hibernate"
  ];
in
{
  options.qnix.system.laptop = {
    enable = lib.mkEnableOption "laptop-specific host behavior" // {
      default = false;
    };

    thermald.enable = lib.mkEnableOption "thermald thermal management" // {
      default = true;
    };

    fwupd.enable = lib.mkEnableOption "fwupd firmware updates" // {
      default = true;
    };

    lid = {
      enable = lib.mkEnableOption "logind lid switch handling" // {
        default = true;
      };

      whenClosed = lib.mkOption {
        type = lidActionType;
        default = "suspend";
        description = "Action when the lid is closed on battery or in the default case.";
      };

      whenClosedExternalPower = lib.mkOption {
        type = lidActionType;
        default = "ignore";
        description = "Action when the lid is closed while external power is connected.";
      };

      whenClosedDocked = lib.mkOption {
        type = lidActionType;
        default = "ignore";
        description = "Action when the lid is closed while docked.";
      };
    };
  };
}
