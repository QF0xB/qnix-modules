{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [
    "desktop.hyprland"
    "desktop.hyprland.special-workspaces"
  ];

  options =
    { lib, ... }:
    {
      additionalKeybinds = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional Hyprland keybind definitions.";
      };
    };

  home =
    {
      context,
      cfg,
      lib,
      ...
    }:
    let
      mod = if context.vm or false then "ALT" else "super";
      uexec = command: "exec, uwsm app -- ${command}";
      workspaces = [
        {
          num = "1";
          code = "58";
          comment = "m";
        }
        {
          num = "2";
          code = "59";
          comment = ",";
        }
        {
          num = "3";
          code = "60";
          comment = ".";
        }
        {
          num = "4";
          code = "44";
          comment = "j";
        }
        {
          num = "5";
          code = "45";
          comment = "k";
        }
        {
          num = "6";
          code = "46";
          comment = "l";
        }
        {
          num = "7";
          code = "30";
          comment = "u";
        }
        {
          num = "8";
          code = "31";
          comment = "i";
        }
        {
          num = "9";
          code = "32";
          comment = "o";
        }
        {
          num = "10";
          code = "65";
          comment = "space";
        }
      ];
      workspaceBindings = builtins.concatLists (
        map (
          workspace:
          let
            shown = if workspace.num == "10" then "0" else workspace.num;
          in
          [
            "${mod}, ${shown}, workspace, ${shown}"
            "${mod}, code:${workspace.code}, workspace, ${workspace.num} #${workspace.comment}"
            "${mod}+SHIFT+CTRL, ${shown}, movetoworkspace, ${shown}"
            "${mod}+SHIFT+CTRL, code:${workspace.code}, movetoworkspace, ${workspace.num} #${workspace.comment}"
            "${mod} CTRL, ${shown}, movetoworkspacesilent, ${shown}"
            "${mod} CTRL, code:${workspace.code}, movetoworkspacesilent, ${workspace.num} #${workspace.comment}"
          ]
        ) workspaces
      );
    in
    {
      wayland.windowManager.hyprland.settings = {
        "$mod" = mod;

        bindl = [
          ",switch:Lid Switch, ${uexec "hyprlock"}"
        ];

        bindm = [
          "${mod}, mouse:272, movewindow"
          "${mod}, mouse:273, resizewindow"
        ];

        bind = [
          "${mod} SHIFT, code:26, exec, ~/.config/hypr/scripts/reload.sh #e"
          "${mod} SHIFT, code:53, exec, uwsm stop #x"
          "${mod}, code:42, exec, hyprctl switchxkblayout all next #g"
          "${mod}, mouse_down, workspace, e+1"
          "${mod}, mouse_up, workspace, e-1"
          "${mod}, code:48, fullscreen #;"
          "${mod}, code:38, killactive #A"
          "${mod} SHIFT, code:48, togglefloating #;"
          "${mod}, code:61, togglesplit, #?"
          "${mod}, Tab, cyclenext"
          "super, Tab, swapnext"
          "CTRL, Tab, workspace, e+"
          "${mod}, left, movefocus, l"
          "${mod}, right, movefocus, r"
          "${mod}, up, movefocus, u"
          "${mod}, down, movefocus, d"
          "${mod}, return, exec, hypr-special scratch scratchpad -- kitty --class scratchpad"
          "${mod} SHIFT, return, ${uexec "kitty"}"
          "${mod} CTRL, return, ${uexec "kitty --class floating"}"
          "${mod}, code:47, ${uexec "brave"} #;"
          "${mod} CTRL, code:47, ${uexec "brave --private-window"} #;"
          "${mod}, code:25, ${uexec "rofi -show drun"} #w"
          "${mod}, code:29, exec, hypr-special recording obs -- obs #y"
          "${mod}, code:40, ${uexec "nemo"} #d"
          "${mod}, code:57, exec, hypr-special secrets Bitwarden -- bitwarden #m"
          "${mod}, code:26, exec, hypr-special notes obsidian -- obsidian #e"
          ", Print, ${uexec "rofi -show drun"}"
          ", xf86audioraisevolume, exec, pamixer -i 5"
          ", xf86audiolowervolume, exec, pamixer -d 5"
          ", xf86AudioMute, exec, pamixer -t"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86audiostop, exec, playerctl stop"
        ]
        ++ workspaceBindings
        ++ cfg.additionalKeybinds;
      };

      home.file.".config/hypr/scripts/reload.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          killall waybar || true
          waybar &
          hyprctl reload
          killall hyprpaper || true
          hyprpaper
        '';
      };
    };
}
