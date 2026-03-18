{
  osConfig,
  lib,
  pkgs,
  isVm,
  ...
}:

let
  cfg = osConfig.qnix.desktop.hyprdesktop;
  keyboards = osConfig.qnix.core.localisation.xkb;
  apps = osConfig.qnix.apps;

  hyprSpecial = pkgs.writeShellApplication {
    name = "hypr-special";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.jq
    ];
    text = ''
      set -eu

      if [ "$#" -lt 4 ] || [ "$3" != "--" ]; then
        echo "usage: hypr-special <specialName> <matchValue> -- <command> [args...]" >&2
        exit 2
      fi

      ws="$1"
      want="$2"
      shift 3  # drop ws, want, --

      exists="$(
        hyprctl -j clients | jq -r --arg v "$want" '
          any(.[]; (.class == $v) or (.initialClass == $v))
        '
      )"

      if [ "$exists" != "true" ]; then
        uwsm app -- "$@" >/dev/null 2>&1 &
      else
        hyprctl dispatch togglespecialworkspace "$ws" >/dev/null
      fi
    '';
  };

  uexec = program: "exec, uwsm app -- ${program} ";
  default-app-uexec = app-name: (uexec (lib.getExe apps.${app-name}));
  # Toggle special workspace: start app if no window with matchClass exists, then toggle workspace
  hypr-special =
    ws: matchClass: cmd:
    "exec, hypr-special ${ws} ${matchClass} -- ${cmd}";

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
  conv = ws: if ws == "10" then "0" else ws;
  generateBindings =
    wRec:
    let
      n = wRec.num;
      c = wRec.code;
      comm = wRec.comment;
      cn = conv n;
    in
    [
      ("$mod, " + cn + ", workspace, " + cn)
      ("$mod, code:" + builtins.toString c + ", workspace, " + n + " #" + comm)
      ("$mod+SHIFT+CTRL, " + cn + ", movetoworkspace, " + cn)
      ("$mod+SHIFT+CTRL, code:" + builtins.toString c + ", movetoworkspace, " + n + " #" + comm)
      ("$mod CTRL, " + cn + ", movetoworkspacesilent, " + cn)
      ("$mod CTRL, code:" + builtins.toString c + ", movetoworkspacesilent, " + n + " #" + comm)
    ];
  bindingLines = builtins.concatLists (map generateBindings workspaces);
in
lib.mkIf (cfg.enable && cfg.hyprsuite.hyprland.setDefaultKeybinds) {
  home.packages = lib.concatLists [
    [ hyprSpecial ]
  ];

  wayland.windowManager.hyprland.settings = {
    "$mod" = if isVm then "ALT" else "super";
    "$ipc" = "noctalia-shell ipc call";

    bindl = [
      ",switch:Lid Switch, ${uexec "hyprlock"}"

      # Media keys
      ", XF86AudioRaiseVolume, exec, $ipc volume increase"
      ", XF86AudioLowerVolume, exec, $ipc volume decrease"
      ", XF86AudioMute, exec, $ipc volume muteOutput"
      ", XF86MonBrightnessUp, exec, $ipc brightness increase"
      ", XF86MonBrightnessDown, exec, $ipc brightness decrease"
    ];

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bind = [
      "$mod SHIFT, code:53, exec, uwsm stop #x"
      "$mod, code:42, exec, hyprctl switchxkblayout all next #g"
      "super, Tab, swapnext"
      "ALT, Tab, cyclenext"
      "CTRL, Tab, workspace, e+1"
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      "$mod, code:25, exec, $ipc launcher toggle"
      "$mod SHIFT, code:25, exec, $ipc controlCenter toggle"
      "ALT, code:46, exec, $ipc lockScreen lock"

      "$mod, code:48, fullscreen #ä"
      "$mod, code:38, killactive #a"
      "$mod SHIFT, code:48, togglefloating #f"
      "$mod SHIFT, return, ${default-app-uexec "terminal"}"
      "$mod CTRL, return, ${default-app-uexec "terminal"} --class floating"
      "$mod, code:47, ${default-app-uexec "browser"} #Ö"
      "$mod SHIFT, code:47, ${default-app-uexec "browser"} --private-window #Ö"
      "$mod, code:40, ${default-app-uexec "file-manager"} #d"

      # Special workspaces (toggle; launch app if no matching window)
      "$mod, return, ${
        hypr-special "scratch" "scratchpad" "${lib.getExe apps.terminal} --class scratchpad"
      } #scratchpad"
      "$mod, code:26, ${hypr-special "notes" "obsidian" (lib.getExe apps.notes)} #e notes"
      "$mod, code:29, ${hypr-special "obs" "obs" "obs-studio"} #z obs"
      "$mod, code:57, ${hypr-special "secrets" "bitwarden" "bitwarden"} #n bitwarden"
      "$mod, code:43, ${hypr-special "music" "tidal-hifi" "tidal-hifi"} #d tidal-hifi"

      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86audiostop, exec, playerctl stop"
    ]
    ++ bindingLines;
  };
}
