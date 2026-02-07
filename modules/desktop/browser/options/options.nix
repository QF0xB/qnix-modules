{
  lib,
  config ? null,
  ...
}:

{
  options.qnix.desktop.browser = {
    enable = lib.mkEnableOption "browser" // {
      default = config != null && !config.qnix.headless;
    };

    firefox = {
      enable = lib.mkEnableOption "Firefox browser" // {
        default = false;
      };
    };

    brave = {
      enable = lib.mkEnableOption "Brave browser (annoying features disabled via policy)" // {
        default = config != null && !config.qnix.headless;
      };
    };
  };
}
