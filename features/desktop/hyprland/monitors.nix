{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.hyprland" ];

  persistence.users."*".files = [
    ".config/hypr/monitors.lua"
    ".config/hypr/workspaces.lua"
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
      home.activation.createHyprMonitorConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -f "$HOME/.config/hypr/monitors.lua" ]; then
          mkdir -p "$HOME/.config/hypr"
          cat > "$HOME/.config/hypr/monitors.lua" <<'EOF'
        hl.monitor({
          output = "",
          mode = "preferred",
          position = "auto",
          scale = 1,
        })
        EOF
        fi
        if [ ! -f "$HOME/.config/hypr/workspaces.lua" ]; then
          mkdir -p "$HOME/.config/hypr"
          touch "$HOME/.config/hypr/workspaces.lua"
        fi
      '';

      wayland.windowManager.hyprland.extraLuaFiles.userConfig.content = ''
        require("monitors")
        require("workspaces")
      '';
    };
}
