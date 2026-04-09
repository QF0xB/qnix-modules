{ lib }:
{
  status.headless = lib.mkDefault false;

  desktop.browser.enable = lib.mkDefault true;
  desktop.clipboard.enable = lib.mkDefault true;
  desktop.fileManager.enable = lib.mkDefault true;
  desktop.lock.enable = lib.mkDefault true;
  desktop.screenshots.enable = lib.mkDefault true;
  desktop.terminal.enable = lib.mkDefault true;
  desktop.xdg-folders.enable = lib.mkDefault true;
}
