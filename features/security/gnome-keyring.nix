{
  environments = [ "nixos" ];

  persistence.users."*".directories = [ ".local/share/keyrings" ];

  options =
    { lib, ... }:
    {
      gui = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to install the Seahorse graphical keyring manager.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    {
      services.gnome.gnome-keyring.enable = true;

      security.pam.services = {
        login.enableGnomeKeyring = true;
        sddm.enableGnomeKeyring = true;
      };

      environment.systemPackages = lib.mkIf cfg.gui [ pkgs.seahorse ];
    };
}
