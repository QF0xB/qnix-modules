{ lib, pkgs, ... }:
{
  options.qnix = {
    status = {
      headless = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      server = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      vm = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };

    system = {
      boot-manager.enable = lib.mkEnableOption "boot manager";
      localisation.enable = lib.mkEnableOption "localisation";
      packages.enable = lib.mkEnableOption "packages";
      users.enable = lib.mkEnableOption "users";
    };

    security = {
      sops.enable = lib.mkEnableOption "sops";
    };

    storage = {
      impermanence.enable = lib.mkEnableOption "impermanence";
    };
  };
}
