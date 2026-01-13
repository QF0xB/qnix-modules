{
  lib,
  config,
  ...
}:

let
  cfg = config.qnix.core.localisation;

  # Extract all unique locales from localeSettings values
  # Convert "de_DE.UTF-8" to "de_DE.UTF-8/UTF-8" format for supportedLocales
  usedLocales = lib.unique (lib.mapAttrsToList (_: value: value) cfg.localeSettings);
  supportedLocales = map (locale: "${locale}/UTF-8") usedLocales;
in
{
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
