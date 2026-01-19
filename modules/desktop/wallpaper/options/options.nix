{
  lib,
  config ? null,
  ...
}:

{
  options.qnix.desktop.waypaper = {
    enable = lib.mkEnableOption "waypaper" // {
      default = config != null && config.qnix.wayland && !config.qnix.headless;
    };
  };
}
