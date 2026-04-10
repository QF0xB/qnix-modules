{ lib, config, ... }:
let
  sharedQnix = import ../shared/base.nix { inherit lib; };
in
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
    (lib.qnix.mkNixosOptionImports {
      category = "storage";
      name = "impermanence";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "system";
      name = "shell";
    })
    (lib.qnix.mkNixosOptionImports {
      category = "system";
      name = "starship";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "system";
      name = "users";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "storage";
      name = "zfs";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "network";
      name = "firewall";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "network";
      name = "addressing";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "network";
      name = "networkmanager";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "network";
      name = "tailscale";
    })
  ];

  config = {
    qnix = lib.recursiveUpdate sharedQnix {
      persist.users."*".directories = [
        ".ssh"
        ".config/sops"
      ];

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

      security.sops.enable = lib.mkDefault true;

      network.firewall.enable = lib.mkDefault true;

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
