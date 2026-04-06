{ lib, config, ... }:

let
  cfg = config.qnix.system.localisation;

  # Extract all unique locales from localeSettings values
  # Convert "de_DE.UTF-8" to "de_DE.UTF-8/UTF-8" format for supportedLocales
  usedLocales = lib.unique (lib.mapAttrsToList (_: value: value) cfg.localeSettings);
  supportedLocales = map (locale: "${locale}/UTF-8") usedLocales;

in
{
  options = {
    qnix.system.localisation = {
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Berlin";
        description = "The timezone to use for the system";
      };

      xkb = {
        layout = lib.mkOption {
          type = lib.types.str;
          default = "de";
          description = "The layouts to use for the keyboard";
        };

        variant = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "The variant to use for the keyboard";
        };

        console-bridge = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable the console bridge";
        };
      };

      localeSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Locale environment variables (LANG, LC_*)";
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
          LC_IDENTIFICATION = "en_US.UTF-8";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
