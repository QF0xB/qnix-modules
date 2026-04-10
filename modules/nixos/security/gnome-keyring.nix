{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.security.gnome-keyring;
in
{
  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true;
      sddm.enableGnomeKeyring = true;
    };

    environment.systemPackages = lib.mkIf cfg.gui [ pkgs.seahorse ];

    qnix.persist.users."*".directories = [
      ".local/share/keyrings"
    ];
  };
}
