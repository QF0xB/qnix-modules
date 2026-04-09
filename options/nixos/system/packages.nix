{ lib, pkgs, ... }:
{
  options.qnix.system.packages = {
    enable = lib.mkEnableOption "packages";

    nerdFonts.enable = lib.mkEnableOption "JetBrains Mono Nerd Font";

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
