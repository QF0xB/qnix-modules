{ lib }:
{
  apps.notes.enable = lib.mkDefault true;
  apps.bitwarden.enable = lib.mkDefault false;
  apps.music.enable = lib.mkDefault true;
  apps.social.enable = lib.mkDefault true;
}
