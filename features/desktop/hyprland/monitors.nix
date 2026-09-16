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
    {
      config,
      lib,
      ...
    }:
    let
      users = lib.attrNames config.qnix.system.users.users;
      migrateUser = username: ''
        for file in monitors.lua workspaces.lua; do
          source="/home/${username}/.config/hypr/$file"
          target="/persist/home/${username}/.config/hypr/$file"

          # An existing persistence mount is already in the correct state.
          if findmnt --mountpoint "$source" -n >/dev/null 2>&1; then
            continue
          fi

          if [ -f "$source" ] && [ ! -e "$target" ]; then
            mkdir -p "$(dirname "$target")"
            mv "$source" "$target"
          elif [ -f "$source" ] && [ -e "$target" ]; then
            backup="$source.pre-persist"
            if [ -e "$backup" ]; then
              backup="$source.pre-persist.$(date +%s)"
            fi
            mv "$source" "$backup"
          fi

          if [ ! -e "$target" ]; then
            mkdir -p "$(dirname "$target")"
            if [ "$file" = "monitors.lua" ]; then
              cat > "$target" <<'EOF'
        hl.monitor({
          output = "",
          mode = "preferred",
          position = "auto",
          scale = 1,
        })
        EOF
            else
              touch "$target"
            fi
          fi
        done
      '';
    in
    {
      system.activationScripts = {
        qnixHyprlandLuaFiles = {
          deps = [ "createPersistentStorageDirs" ];
          text = lib.concatMapStringsSep "\n" (username: migrateUser username) users;
        };
        "persist-files".deps = [ "qnixHyprlandLuaFiles" ];
      };
    };

  home =
    {
      ...
    }:
    {
      wayland.windowManager.hyprland.extraLuaFiles.userConfig.content = ''
        require("monitors")
        require("workspaces")
      '';
    };
}
