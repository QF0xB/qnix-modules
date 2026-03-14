{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.qnix.core.passwords.keyring.gnome.enable {
    services.gnome.gnome-keyring.enable = true;

    # Make sure your login/session unlocks the keyring via PAM.
    # Adjust these services to match how you log in (sddm, greetd, tty, etc.)
    security.pam.services = {
      login.enableGnomeKeyring = true;
      # If you use a display manager, add it too, e.g.:
      sddm.enableGnomeKeyring = true;
    };

    # Optional GUI to inspect/edit secrets
    environment.systemPackages = lib.mkIf config.qnix.core.passwords.keyring.gnome.gui [
      pkgs.seahorse
    ];

    qnix.persist.home.directories = [
      ".local/share/keyrings"
    ];
  };
}
