{ lib, config, ... }:
{
  imports = lib.concatLists [
    # Sops MUST be imported before any modules that use it
    (lib.qnix.mkNixosFeatureImports {
      category = "security";
      name = "sops";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "system";
      name = "boot";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "system";
      name = "localisation";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "system";
      name = "packages";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "system";
      name = "users";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "security";
      name = "firewall";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "storage";
      name = "zfs";
    })
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
