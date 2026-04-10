{ lib, ... }:
{
  options.qnix.security.gnome-keyring = {
    enable = lib.mkEnableOption "GNOME keyring";

    gui = lib.mkEnableOption "GNOME keyring GUI tools";
  };
}
