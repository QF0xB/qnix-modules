{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  pkgs,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  hyprCfg = qconfig.desktop.hyprland or { enable = false; };
  cfg = hyprCfg.keybinds or { enable = true; };
  isVm = qconfig.status.vm or false;
  isLaptop = qconfig.status.laptop or false;
  terminalPackage = qconfig.desktop.terminal.package or pkgs.kitty;
  terminalExe = lib.getExe terminalPackage;
  browserCfg =
    qconfig.desktop.browser or {
      enable = false;
      privateArgs = [ ];
    };
  clipboardCfg =
    qconfig.desktop.clipboard or {
      enable = false;
      package = pkgs.cliphist;
      pickerPackage = pkgs.fuzzel;
    };
  fileManagerCfg = qconfig.desktop.fileManager or { enable = false; };
  notesCfg = qconfig.desktop.notes or { enable = false; };
  lockCfg = qconfig.desktop.lock or { enable = false; };
  obsCfg = qconfig.desktop.obs or { enable = false; };
  bitwardenCfg = qconfig.desktop.bitwarden or { enable = false; };
  musicCfg = qconfig.desktop.music or { enable = false; };
  screenshotsCfg =
    qconfig.desktop.screenshots or {
      enable = false;
      grimPackage = pkgs.grim;
      slurpPackage = pkgs.slurp;
      annotationTool = "";
    };
  browserExe = if browserCfg.enable then lib.getExe browserCfg.package else null;
  fileManagerExe = if fileManagerCfg.enable then lib.getExe fileManagerCfg.package else null;
  notesExe = if notesCfg.enable then lib.getExe notesCfg.package else null;
  lockExe = if lockCfg.enable then lib.getExe lockCfg.package else null;
  obsExe = if obsCfg.enable then lib.getExe obsCfg.package else null;
  bitwardenExe = if bitwardenCfg.enable then lib.getExe bitwardenCfg.package else null;
  musicExe = if musicCfg.enable then lib.getExe musicCfg.package else null;
  clipboardExe = if clipboardCfg.enable then lib.getExe clipboardCfg.package else null;
  clipboardPickerExe = if clipboardCfg.enable then lib.getExe clipboardCfg.pickerPackage else null;

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
      shift 3

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

  optionalRunner = pkgs.writeShellApplication {
    name = "hypr-optional-run";
    text = ''
      set -eu

      if [ "$#" -lt 2 ] || [ "$1" != "--" ]; then
        echo "usage: hypr-optional-run -- <command> [args...]" >&2
        exit 2
      fi

      shift

      if command -v "$1" >/dev/null 2>&1; then
        exec "$@"
      fi
    '';
  };

  clipboardPicker =
    if clipboardCfg.enable then
      pkgs.writeShellApplication {
        name = "hypr-clipboard-picker";
        runtimeInputs = [
          clipboardCfg.package
          clipboardCfg.pickerPackage
          pkgs.wl-clipboard
          pkgs.libnotify
        ];
        text = ''
          set -eu

          selection="$(${clipboardExe} list | ${clipboardPickerExe} --dmenu --prompt "Clipboard> " || true)"

          if [ -z "$selection" ]; then
            exit 0
          fi

          printf '%s\n' "$selection" | ${clipboardExe} decode | wl-copy
          notify-send "Clipboard" "Entry copied to clipboard"
        '';
      }
    else
      null;

  screenshotTool =
    if screenshotsCfg.enable then
      pkgs.writeShellApplication {
        name = "hypr-screenshot";
        runtimeInputs = [
          screenshotsCfg.grimPackage
          screenshotsCfg.slurpPackage
          pkgs.wl-clipboard
          pkgs.coreutils
          pkgs.bash
          pkgs.libnotify
        ];
        text = ''
          set -eu

          if [ "$#" -lt 1 ]; then
            echo "usage: hypr-screenshot <full|region|region-annotate>" >&2
            exit 2
          fi

          mode="$1"
          dir="$HOME/Pictures/Screenshots"
          mkdir -p "$dir"
          file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

          case "$mode" in
            full)
              ${lib.getExe screenshotsCfg.grimPackage} "$file"
              ;;
            region|region-annotate)
              ${lib.getExe screenshotsCfg.grimPackage} -g "$(${lib.getExe screenshotsCfg.slurpPackage})" "$file"
              ;;
            *)
              echo "unknown screenshot mode: $mode" >&2
              exit 2
              ;;
          esac

          wl-copy < "$file"
          notify-send "Screenshot" "Saved to $file and copied to clipboard"

          if [ "$mode" = "region-annotate" ] && [ -n "${screenshotsCfg.annotationTool}" ]; then
            exec sh -lc '${screenshotsCfg.annotationTool} "$1"' _ "$file"
          fi
        '';
      }
    else
      null;

  uexec = program: "exec, uwsm app -- ${program}";
  optionalExec = command: "exec, ${lib.getExe optionalRunner} -- ${command}";
  hyprSpecialExec =
    ws: matchClass: cmd:
    "exec, ${lib.getExe hyprSpecial} ${ws} ${matchClass} -- ${cmd}";

  workspaces = [
    {
      num = "1";
      code = "58";
    }
    {
      num = "2";
      code = "59";
    }
    {
      num = "3";
      code = "60";
    }
    {
      num = "4";
      code = "44";
    }
    {
      num = "5";
      code = "45";
    }
    {
      num = "6";
      code = "46";
    }
    {
      num = "7";
      code = "30";
    }
    {
      num = "8";
      code = "31";
    }
    {
      num = "9";
      code = "32";
    }
    {
      num = "10";
      code = "65";
    }
  ];

  conv = ws: if ws == "10" then "0" else ws;

  workspaceBindings = builtins.concatLists (
    map (workspace: [
      "$mod, ${conv workspace.num}, workspace, ${conv workspace.num}"
      "$mod, code:${workspace.code}, workspace, ${workspace.num}"
      "$mod+SHIFT+CTRL, ${conv workspace.num}, movetoworkspace, ${conv workspace.num}"
      "$mod+SHIFT+CTRL, code:${workspace.code}, movetoworkspace, ${workspace.num}"
      "$mod CTRL, ${conv workspace.num}, movetoworkspacesilent, ${conv workspace.num}"
      "$mod CTRL, code:${workspace.code}, movetoworkspacesilent, ${workspace.num}"
    ]) workspaces
  );
in
{
  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [
      hyprSpecial
    ];

    wayland.windowManager.hyprland.settings = {
      "$mod" = if isVm then "ALT" else "super";
      "$ipc" = "${lib.getExe optionalRunner} -- noctalia-shell ipc call";

      bindl =
        lib.optional (lockExe != null) ",switch:Lid Switch, ${optionalExec lockExe}"
        ++ [
        ", XF86AudioRaiseVolume, exec, $ipc volume increase"
        ", XF86AudioLowerVolume, exec, $ipc volume decrease"
        ", XF86AudioMute, exec, $ipc volume muteOutput"
      ]
        ++ lib.optionals isLaptop [
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
        "$mod, code:48, fullscreen #f"
        "$mod, code:38, killactive #a"
        "$mod SHIFT, code:48, togglefloating #f"
        "$mod SHIFT, return, ${uexec terminalExe}"
        "$mod CTRL, return, ${uexec "${terminalExe} --class floating"}"
        "$mod, return, ${
          hyprSpecialExec "scratch" "scratchpad" "${terminalExe} --class scratchpad"
        } #scratchpad"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86audiostop, exec, playerctl stop"
      ]
      ++ lib.optional (lockExe != null) "$mod SHIFT, code:46, ${optionalExec lockExe} # L"
      ++ lib.optional (browserExe != null) "$mod, code:47, ${optionalExec browserExe} #Ö"
      ++
        lib.optional (browserExe != null)
          "$mod SHIFT, code:47, ${
            optionalExec (lib.concatStringsSep " " ([ browserExe ] ++ browserCfg.privateArgs))
          } #Ö"
      ++ lib.optional (fileManagerExe != null) "$mod, code:40, ${uexec fileManagerExe} #d"
      ++
        lib.optional (notesExe != null)
          "$mod, code:26, ${hyprSpecialExec "notes" "obsidian" notesExe} #e notes"
      ++ lib.optional (obsExe != null) "$mod, code:29, ${hyprSpecialExec "obs" "obs" obsExe} #z obs"
      ++
        lib.optional (bitwardenExe != null)
          "$mod, code:57, ${hyprSpecialExec "secrets" "bitwarden" bitwardenExe} #n bitwarden"
      ++
        lib.optional (musicExe != null)
          "$mod, code:43, ${hyprSpecialExec "music" "tidal-hifi" musicExe} #d tidal-hifi"
      ++ lib.optional clipboardCfg.enable "$mod, code:55, exec, ${lib.getExe clipboardPicker}"
      ++ lib.optional screenshotsCfg.enable ", Print, exec, ${lib.getExe screenshotTool} full"
      ++ lib.optional screenshotsCfg.enable "SHIFT, Print, exec, ${lib.getExe screenshotTool} region"
      ++
        lib.optional
          (screenshotsCfg.enable && screenshotsCfg.annotationTool != "")
          "CTRL, Print, exec, ${lib.getExe screenshotTool} region-annotate"
      ++ workspaceBindings;
    };
  };
}
