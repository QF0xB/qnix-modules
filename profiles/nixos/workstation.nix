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
    };
  };
}
