{ lib }:
{
  system = {
    packages.nerdFonts.enable = lib.mkOverride 900 true;

    starship.enable = lib.mkOverride 900 true;

    shell = {
      showIcons = lib.mkDefault true;
    };

    starship.showIcons = lib.mkDefault true;
  };

  security.gpg.enable = lib.mkDefault true;
}
