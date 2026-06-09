{ lib }:
{
  apps.notes.enable = lib.mkDefault true;
  apps.bitwarden.enable = lib.mkDefault false; # TODO: Enable this when the package is available in nixpkgs
  apps.music.enable = lib.mkDefault true;
  apps.social.enable = lib.mkDefault true;
}
