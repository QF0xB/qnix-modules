{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires = {
    nixos = [ "desktop.wayland" ];
    home = [ "desktop.wayland" ];
  };

  options =
    { lib, ... }:
    {
      noHardwareCursors = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to disable hardware cursors for Hyprland.";
      };
    };

  nixos =
    { ... }:
    {
      programs.hyprland.enable = true;
    };

  home =
    {
      cfg,
      ...
    }:
    {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        settings = {
          cursor.no_hardware_cursors = cfg.noHardwareCursors;
        };
      };
    };
}
