{ lib }:
{
  apps.notes.enable = lib.mkDefault true;
  apps.bitwarden.enable = lib.mkDefault true;
  apps.music.enable = lib.mkDefault true;
}
