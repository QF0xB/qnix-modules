{ lib }:
{
  status.headless = lib.mkDefault false;

  desktop.terminal.enable = lib.mkDefault true;
  desktop.xdg-folders.enable = lib.mkDefault true;
}
