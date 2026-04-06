{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.security.yubikey;
  u2fEnabled = cfg.login || cfg.sudo;
  authFile = pkgs.writeText "u2f-mappings" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        username: mappings: "${username}:${lib.concatStringsSep ":" mappings}"
      ) cfg.u2f.mappings
    )
  );
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = (!u2fEnabled) || cfg.u2f.mappings != { };
            message = "qnix.security.yubikey.u2f.mappings must be set when yubikey login or sudo auth is enabled.";
          }
        ];

        services.udev = {
          packages = [ pkgs.yubikey-personalization ];

          extraRules = lib.strings.concatStrings [
            ""
            (
              if cfg.autoLock then
                ''
                  ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="1050", ENV{ID_VENDOR}=="Yubico", TAG+="systemd"
                ''
              else
                ""
            )
          ];
        };

        hardware = {
          gpgSmartcards.enable = true;
        };

        services.pcscd.enable = true;

        environment.systemPackages = lib.mkIf cfg.gui [ pkgs.yubioath-flutter ];
      }

      (lib.mkIf u2fEnabled {
        security.pam = {
          u2f = {
            enable = true;

            settings = {
              cue = cfg.u2f.cue;
              origin = cfg.u2f.origin;
              authfile = authFile;
            };
          };

          services = {
            login.u2fAuth = cfg.login;
            sudo.u2fAuth = cfg.sudo;
          };
        };
      })
    ]
  );
}
