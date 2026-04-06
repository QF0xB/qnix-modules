{ lib, config, ... }:
{
  imports = [
    # Sops MUST be imported before any modules that use it
    ../../modules/nixos/security/sops.nix

    ../../modules/nixos/system/boot.nix
    ../../modules/nixos/system/localisation.nix
    ../../modules/nixos/system/packages.nix
    ../../modules/nixos/system/users.nix

    ../../modules/nixos/security/firewall.nix

    ../../modules/nixos/storage/zfs.nix
  ];

  config = {
    qnix = {
      system = {
        boot-manager.enable = lib.mkDefault true;
        localisation.enable = lib.mkDefault true;
        packages.enable = lib.mkDefault true;
        users = {
          enable = lib.mkDefault true;
          defaultExtraGroups = lib.mkDefault [ "wheel" ];
          root = {
            enable = lib.mkDefault false;
          };
        };
      };

      security = {
        firewall.enable = lib.mkDefault true;
        sops.enable = lib.mkDefault true;
      };

      storage = {
        zfs.enable = lib.mkDefault true;
      };
    };

    nix.settings.experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];
  };
}
