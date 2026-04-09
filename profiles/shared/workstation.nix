{ lib }:
{
  status = {
    server = lib.mkDefault false;
  };

  system = {
    starship.enable = lib.mkOverride 900 true;

    shell = {
      showIcons = lib.mkDefault true;
    };

    starship.showIcons = lib.mkDefault true;
  };

  security.gpg.enable = lib.mkDefault true;

  dev.git = {
    enable = lib.mkDefault true;
  };
}
