{ lib, pkgs, ... }:
{
  options.qnix.system.packages = {
    enable = lib.mkEnableOption "packages";

    editor = lib.mkOption {
      type = lib.types.package;
      default = pkgs.neovim;
      description = "The editor to use for the system";
    };

    extra = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to install";
    };
  };
}
