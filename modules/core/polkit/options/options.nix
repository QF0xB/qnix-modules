{ lib, ... }:

{
  options.qnix.core.polkit = {
    enable = lib.mkEnableOption "polkit" // {
      default = true;
    };

    allowUserPowerCommands = lib.mkEnableOption "allow user to execute power commands" // {
      default = true;
      description = "Whether to allow user to execute power commands";
    };
  };
}
