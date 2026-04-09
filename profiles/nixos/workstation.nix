{ lib, config, ... }:

let
  sharedQnix = import ../shared/workstation.nix { inherit lib; };
in
{
  imports = lib.concatLists [
    (lib.qnix.mkNixosFeatureImports {
      category = "dev";
      name = "nh";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "system";
      name = "localisation";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "security";
      name = "sops";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "security";
      name = "gpg";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "security";
      name = "yubikey";
    })
  ];

  config = {
    qnix = lib.recursiveUpdate sharedQnix {
      status = {
        headless = lib.mkDefault false;
        server = lib.mkDefault false;
      };

      dev = {
        nh = {
          enable = lib.mkDefault true;
          clean.enable = lib.mkDefault true;
        };
      };

      system = {
        packages.nerdFonts.enable = lib.mkDefault true;

        localisation = {
          enable = lib.mkDefault true;
          xkb = {
            layout = lib.mkDefault "de,de,us";
            variant = lib.mkDefault "koy, , ";
          };
        };

        shell = {
          defaultShell = {
            package = lib.mkDefault "fish";
          };
          fish.enable = lib.mkDefault true;
        };
      };

      network.networkmanager = {
        enable = lib.mkDefault true;
        gui = lib.mkDefault true;
      };

      security = {
        sops = {
          enable = lib.mkDefault true;
          defaultSopsFile = lib.mkDefault "./secrets/default.yaml";
          age = {
            keyFile = lib.mkDefault "~/.config/sops/age/keys/default.key";
          };
        };
        yubikey = {
          enable = lib.mkDefault true;
        };
      };
    };
  };
}
