{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    let
      logindAction = lib.types.enum [
        "ignore"
        "poweroff"
        "reboot"
        "halt"
        "kexec"
        "suspend"
        "hibernate"
        "hybrid-sleep"
        "lock"
      ];
    in
    {
      touchpad = {
        tapping = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether tapping should act as a touchpad click.";
        };

        naturalScrolling = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether touchpad scrolling should follow finger movement.";
        };
      };

      lidSwitch = lib.mkOption {
        type = logindAction;
        default = "suspend";
        description = "Action taken when the laptop lid is closed.";
      };

      lidSwitchExternalPower = lib.mkOption {
        type = logindAction;
        default = "lock";
        description = "Action taken when the lid is closed while on external power.";
      };

      lidSwitchDocked = lib.mkOption {
        type = logindAction;
        default = "ignore";
        description = "Action taken when the lid is closed while docked.";
      };

      powerKey = lib.mkOption {
        type = logindAction;
        default = "suspend";
        description = "Action taken when the power button is pressed.";
      };
    };

  nixos =
    {
      cfg,
      ...
    }:
    {
      services.libinput = {
        enable = true;
        touchpad = {
          tapping = cfg.touchpad.tapping;
          naturalScrolling = cfg.touchpad.naturalScrolling;
        };
      };

      services.logind.settings.Login = {
        HandleLidSwitch = cfg.lidSwitch;
        HandleLidSwitchExternalPower = cfg.lidSwitchExternalPower;
        HandleLidSwitchDocked = cfg.lidSwitchDocked;
        HandlePowerKey = cfg.powerKey;
      };
    };
}
