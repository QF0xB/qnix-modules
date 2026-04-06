{ lib, config, ... }:
{
  imports = lib.concatLists [
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
    qnix = {
      status = {
        headless = lib.mkDefault false;
        server = lib.mkDefault false;
      };

      system = {
        localisation = {
          enable = lib.mkDefault true;
          xkb = {
            layout = lib.mkDefault "de,de,us";
            variant = lib.mkDefault "koy, , ";
          };
        };
      };

      security = {
        gpg = {
          enable = lib.mkDefault true;
        };
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
