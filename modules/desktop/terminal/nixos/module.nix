{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.qnix.desktop.terminal.enable {
    qnix.apps.terminal = pkgs.kitty;
  };
}
