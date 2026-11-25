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

      touchDetector = lib.mkOption {
        type = lib.types.bool;
        default = isGraphical;
        description = "Whether to notify when a YubiKey operation is waiting for a touch.";
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

      polkit = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to allow YubiKey authentication for polkit prompts.";
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
      u2fEnabled = cfg.login || cfg.sudo || cfg.polkit;
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
          message = "qnix.security.yubikey.u2f.mappings must be set when login, sudo or polkit authentication is enabled.";
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

      environment.systemPackages =
        lib.optionals cfg.gui [ pkgs.yubioath-flutter ]
        ++ lib.optional cfg.touchDetector pkgs.yubikey-touch-detector
        ++ lib.optional u2fEnabled pkgs.pam_u2f;

      systemd.user.services.yubikey-touch-detector = lib.mkIf cfg.touchDetector {
        description = "Notify when a YubiKey operation is waiting for a touch";
        wantedBy = [ "graphical-session.target" ];
        path = [ pkgs.gnupg ];
        serviceConfig = {
          ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector --notify";
          Restart = "on-failure";
        };
      };

      security.pam.u2f = {
        # The global switch is the default for every PAM service's u2f.enable,
        # which would turn the key on for su, swaylock, run0 and every other
        # service. Only the services below opt in.
        enable = false;
        control = "sufficient";
        settings = {
          cue = cfg.u2f.cue;
          origin = cfg.u2f.origin;
          authfile = authFile;
        };
      };

      # pam_u2f keeps nixpkgs' rule order, ahead of the password. With the key
      # plugged in it waits for a touch; without it, it fails at once and the
      # stack falls through to the password prompt.
      security.pam.services = lib.mapAttrs (_: enabled: lib.mkIf enabled { u2f.enable = true; }) {
        login = cfg.login;
        sddm = cfg.login;
        sudo = cfg.sudo;
        polkit-1 = cfg.polkit;
      };
    };
}
