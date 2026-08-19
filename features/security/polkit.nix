{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      allowUserPowerCommands = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether members of the users group may reboot or power off through logind.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      ...
    }:
    {
      security.polkit = {
        enable = true;
        extraConfig = lib.mkAfter (
          lib.optionalString cfg.allowUserPowerCommands ''
            polkit.addRule(function(action, subject) {
              if (
                subject.isInGroup("users")
                && (
                  action.id == "org.freedesktop.login1.reboot" ||
                  action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                  action.id == "org.freedesktop.login1.power-off" ||
                  action.id == "org.freedesktop.login1.power-off-multiple-sessions"
                )
              ) {
                return polkit.Result.YES;
              }
            });
          ''
        );
      };
    };
}
