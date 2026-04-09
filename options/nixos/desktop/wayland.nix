{ lib, pkgs, ... }:
{
  options.qnix.desktop.wayland = {
    enable = lib.mkEnableOption "Wayland compositor session support";

    portal = {
      enable = lib.mkEnableOption "xdg-desktop-portal integration" // {
        default = true;
      };

      xdgOpenUsePortal = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether xdg-open should prefer the desktop portal.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.xdg-desktop-portal-gtk;
        description = "Default xdg-desktop-portal backend package.";
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Additional xdg-desktop-portal backend packages.";
      };
    };
  };
}
