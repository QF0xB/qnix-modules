{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.hyprland" ];

  persistence.users."*".files = [
    ".config/hypr/monitors.conf"
    ".config/hypr/workspaces.conf"
  ];

  nixos =
    { ... }:
    { };

  home =
    {
      lib,
      ...
    }:
    {
      home.activation.createHyprMonitorConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -f "$HOME/.config/hypr/monitors.conf" ]; then
          mkdir -p "$HOME/.config/hypr"
          cat > "$HOME/.config/hypr/monitors.conf" << EOF
        # Default Hyprland monitor configuration
        # You can customize this file after it is created.
        monitor = , preferred, auto, 1
        EOF
        fi
        if [ ! -f "$HOME/.config/hypr/workspaces.conf" ]; then
          mkdir -p "$HOME/.config/hypr"
          touch "$HOME/.config/hypr/workspaces.conf"
        fi
      '';

      wayland.windowManager.hyprland.settings.source = [
        "~/.config/hypr/monitors.conf"
        "~/.config/hypr/workspaces.conf"
      ];
    };
}
