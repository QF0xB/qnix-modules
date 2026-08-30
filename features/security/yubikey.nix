{
  environments = [ "nixos" ];

  options =
    {
      isGraphical,
      lib,
      ...
    }:
    {
      gui = lib.mkOption {
        type = lib.types.bool;
        default = isGraphical;
        description = "Whether to install the YubiKey graphical management tools.";
      };

      login = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to allow YubiKey authentication for login.";
      };

      sudo = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to allow YubiKey authentication for sudo.";
      };

      autoLock = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to mark YubiKey removal events for systemd handling.";
      };

      u2f = {
        mappings = lib.mkOption {
          type = lib.types.attrsOf (lib.types.listOf lib.types.str);
          default = { };
          description = "PAM U2F mappings keyed by username.";
        };

        cue = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether PAM U2F should prompt the user to touch the key.";
        };

        origin = lib.mkOption {
          type = lib.types.str;
          default = "pam://yubi";
          description = "Origin value passed to PAM U2F.";
        };
      };
    };

  nixos =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    let
      u2fEnabled = cfg.login || cfg.sudo;
      authFile = pkgs.writeText "qnix-yubikey-u2f-mappings" (
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            username: mappings: "${username}:${lib.concatStringsSep ":" mappings}"
          ) cfg.u2f.mappings
        )
      );
    in
    {
      assertions = [
        {
          assertion = !u2fEnabled || cfg.u2f.mappings != { };
          message = "qnix.security.yubikey.u2f.mappings must be set when login or sudo authentication is enabled.";
        }
      ];

      services.pcscd.enable = true;
      hardware.gpgSmartcards.enable = true;
      services.udev.packages = [ pkgs.yubikey-personalization ];

      services.udev.extraRules = lib.mkAfter (
        lib.optionalString cfg.autoLock ''
          ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="1050", ENV{ID_VENDOR}=="Yubico", TAG+="systemd"
        ''
      );

      environment.systemPackages = lib.mkIf cfg.gui [ pkgs.yubioath-flutter ];

      security.pam.u2f = {
        enable = u2fEnabled;
        settings = {
          cue = cfg.u2f.cue;
          origin = cfg.u2f.origin;
          authfile = authFile;
        };
      };

      security.pam.services = {
        login.u2f.enable = cfg.login;
        sudo.u2f.enable = cfg.sudo;
      };
    };
}
