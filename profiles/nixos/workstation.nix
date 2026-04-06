{ lib, config, ... }:
{
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
        sops = {
          enable = lib.mkDefault true;
          defaultSecretFile = lib.mkDefault "./secrets/default.yaml";
          age = {
            keyFile = lib.mkDefault "~/.config/sops/age/keys/default.key";
            keyType = lib.mkDefault "rsa";
          };
        };
      };
    };
  };
}
