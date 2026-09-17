{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  options =
    { lib, ... }:
    {
      enableXWayland = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable XWayland compatibility.";
      };

      enableWlrPortal = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable the wlroots XDG desktop portal.";
      };

      enableGtkPortal = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to add the GTK XDG desktop portal.";
      };

      xdgOpenUsePortal = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether xdg-open should route through the XDG portal.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    {
      programs.dconf.enable = lib.mkDefault true;
      programs.xwayland.enable = lib.mkIf cfg.enableXWayland (lib.mkDefault true);

      services.graphical-desktop.enable = true;
      services.xserver.desktopManager.runXdgAutostartIfNone = lib.mkDefault true;

      xdg.portal = {
        enable = true;
        extraPortals = lib.mkIf cfg.enableGtkPortal [ pkgs.xdg-desktop-portal-gtk ];
        wlr.enable = lib.mkIf cfg.enableWlrPortal true;
        xdgOpenUsePortal = cfg.xdgOpenUsePortal;
      };
    };

  home =
    {
      cfg,
      lib,
      ...
    }:
    {
      home.sessionVariables = lib.mkIf cfg.xdgOpenUsePortal {
        NIXOS_XDG_OPEN_USE_PORTAL = "1";
      };
    };
}
