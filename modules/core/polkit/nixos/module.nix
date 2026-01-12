{ lib, config, ... }:

let
  cfg = config.hm.qnix.core.polkit;
in
{
  config = lib.mkIf cfg.enable {
    security.polkit = {
      enable = true;

      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            )
          )
        });
      '';
    };
  };
}
