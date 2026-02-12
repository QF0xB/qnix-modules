{ lib, ... }:

{
  options.qnix.core.passwords.bitwarden = {
    desktop = {
      enable = lib.mkEnableOption "bitwarden desktop" // {
        default = false;
      };
    };
    cli = {
      enable = lib.mkEnableOption "bitwarden nixos" // {
        default = true;
      };
    };
  };
}
