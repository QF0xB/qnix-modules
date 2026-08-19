{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Berlin";
        description = "The system timezone.";
      };

      xkb = {
        layout = lib.mkOption {
          type = lib.types.str;
          default = "de";
          description = "The keyboard layout or layouts.";
        };

        variant = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "The keyboard variant or variants.";
        };

        console-bridge = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether the console should use the XKB configuration";
        };
      };

      localeSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          LANG = "en_US.UTF-8";
          LC_CTYPE = "en_US.UTF-8";
          LC_NUMERIC = "de_DE.UTF-8";
          LC_TIME = "de_DE.UTF-8";
          LC_COLLATE = "en_US.UTF-8";
          LC_MONETARY = "de_DE.UTF-8";
          LC_MESSAGES = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_ADDRESS = "de_DE.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_MEASUREMENT = "de_DE.UTF-8";
          LC_IDENTIFICATION = "de_DE.UTF-8";
        };
        description = "Locale environment variables.";
      };
    };

  nixos =
    { cfg, ... }:
    let
      usedLocales = lib.unique (builtins.attrValues cfg.localeSettings);
      supportedLocales = map (locale: "${locale}/UTF-8") usedLocales;
    in
    {
      services.xserver.xkb = {
        layout = cfg.xkb.layout;
        variant = cfg.xkb.variant;
      };

      console.useXkbConfig = cfg.xkb.console-bridge;

      time.timeZone = cfg.timezone;

      i18n = {
        supportedLocales = supportedLocales;
        extraLocaleSettings = cfg.localeSettings;
      };
    };
}
