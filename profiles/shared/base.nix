{ lib }:
{
  system = {
    shell.enable = lib.mkDefault true;
    starship = {
      enable = lib.mkDefault false;
    };
  };
}
