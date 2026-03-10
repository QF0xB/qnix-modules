{ lib, ... }:

{
  options.qnix.core.passwords.keyring = {
    gnome = {
      enable = lib.mkEnableOption "gnome keyring" // {
        default = true;
      };
      gui = lib.mkEnableOption "gnome keyring gui" // {
        default = false;
      };
    };
  };
}
