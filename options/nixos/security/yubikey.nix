{ lib, config, ... }:
{
  options.qnix.security.yubikey = {
    enable = lib.mkEnableOption "yubikey";

    gui = lib.mkEnableOption "yubikey GUI" // {
      default = !config.qnix.status.headless;
    };

    login = lib.mkEnableOption "login with yubikey" // {
      default = !config.qnix.status.server;
    };

    sudo = lib.mkEnableOption "sudo with yubikey" // {
      default = !config.qnix.status.server;
    };

    autoLock = lib.mkEnableOption "auto lock yubikey" // {
      default = false;
    };

    u2f = {
      mappings = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
        description = ''
          PAM U2F mappings keyed by username. Each list item is one credential
          mapping segment in pam_u2f format, for example
          `"keyHandle,publicKey,es256,+presence"`.
        '';
        example = {
          q.braendli = [
            "WL1eNX3H4cqCpOdlFLskeKHVkf+SUVng34Ch6rxwn5gw+bJrTyH7wBaYE/iY0Rl4Ab0mNJrTtoUqjLaRNvhWbA==,DX5g1dye2T+mX8tNyMg05W3NrbDE527OCWv6BcUgb63H0zEu4BEl9zWlf3tVOINlqyHcS988QVzfzfHKXT5Abw==,es256,+presence"
          ];
        };
      };

      cue = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether pam_u2f should cue for touch.";
      };

      origin = lib.mkOption {
        type = lib.types.str;
        default = "pam://yubi";
        description = "Origin value for pam_u2f.";
      };
    };
  };
}
