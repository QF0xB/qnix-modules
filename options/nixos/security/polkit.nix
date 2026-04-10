{ lib, ... }:
{
  options.qnix.security.polkit = {
    enable = lib.mkEnableOption "polkit";

    allowUserPowerCommands = lib.mkEnableOption "allow users to execute power commands" // {
      default = true;
      description = "Whether members of the users group may reboot or power off via logind.";
    };
  };
}
