{ lib, ... }:

{
  options.qnix.core.localisation = {
    enable = lib.mkEnableOption "localisation" // {
      default = true;
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "The timezone to use";
    };

    xkb = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "de,de,us";
        description = "The keyboard layout to use";
      };

      variant = lib.mkOption {
        type = lib.types.str;
        default = "koy, ,";
        description = "The keyboard variant to use";
      };

      console-bridge = lib.mkEnableOption "xkb-console-bridge" // {
        default = true;
        description = "Whether to use the xkb-console-bridge";
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
      example = {
        LANG = "en_US.UTF-8";
        LC_TIME = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
      };
    };
  };
}
