{
  config ? null,
  lib,
  ...
}:

{
  options.qnix.desktop.terminal = {
    enable = lib.mkEnableOption "terminal" // {
      default = config != null && !config.qnix.headless;
    };
  };
}
