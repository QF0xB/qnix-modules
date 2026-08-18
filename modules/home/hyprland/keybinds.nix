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
    qconfig.apps.browser or {
      enable = false;
      privateArgs = [ ];
    };
  clipboardCfg =
    qconfig.desktop.clipboard or {
      enable = false;
      package = pkgs.cliphist;
      pickerPackage = pkgs.fuzzel;
    };
  fileManagerCfg = qconfig.apps.fileManager or { enable = false; };
  notesCfg = qconfig.apps.notes or { enable = false; };
  lockCfg = qconfig.desktop.lock or { enable = false; };
  obsCfg = qconfig.apps.obs or { enable = false; };
  bitwardenCfg = qconfig.apps.bitwarden or { enable = false; };
  musicCfg = qconfig.apps.music or { enable = false; };
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

  uexec = program: "uwsm app -- ${program}";
  optionalExec = command: "${lib.getExe optionalRunner} -- ${command}";
  hyprSpecialExec =
    ws: matchClass: cmd:
    "${lib.getExe hyprSpecial} ${ws} ${matchClass} -- ${cmd}";
  mod = if isVm then "ALT" else "SUPER";
  ipc = "${lib.getExe optionalRunner} -- noctalia-shell ipc call";

  luaInline = lib.generators.mkLuaInline;
  luaString = builtins.toJSON;
  execDispatcher = command: "hl.dsp.exec_cmd(${luaString command})";
  specialAppDispatcher = workspace: command: ''
    function()
      local special_workspace = hl.get_workspace(${luaString "special:${workspace}"})
      if special_workspace == nil or special_workspace.windows == 0 then
        hl.exec_cmd(${luaString (uexec command)})
      else
        hl.dispatch(hl.dsp.workspace.toggle_special(${luaString workspace}))
      end
    end
  '';
  focusWorkspaceDispatcher = workspace: "hl.dsp.focus({ workspace = ${luaString workspace} })";
  moveWorkspaceDispatcher =
    workspace: follow:
    "hl.dsp.window.move({ workspace = ${luaString workspace}, follow = ${
      if follow then "true" else "false"
    } })";
  mkBind = key: dispatcher: {
    _args = [
      key
      (luaInline dispatcher)
    ];
  };
  mkBindWith = key: dispatcher: options: {
    _args = [
      key
      (luaInline dispatcher)
      options
    ];
  };

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
      (mkBind "${mod} + ${conv workspace.num}" (focusWorkspaceDispatcher (conv workspace.num)))
      (mkBind "${mod} + code:${workspace.code}" (focusWorkspaceDispatcher workspace.num))
      (mkBind "${mod} + SHIFT + CTRL + ${conv workspace.num}" (
        moveWorkspaceDispatcher (conv workspace.num) true
      ))
      (mkBind "${mod} + SHIFT + CTRL + code:${workspace.code}" (
        moveWorkspaceDispatcher workspace.num true
      ))
      (mkBind "${mod} + CTRL + ${conv workspace.num}" (
        moveWorkspaceDispatcher (conv workspace.num) false
      ))
      (mkBind "${mod} + CTRL + code:${workspace.code}" (moveWorkspaceDispatcher workspace.num false))
    ]) workspaces
  );
in
{
  config = lib.mkIf (hyprCfg.enable && cfg.enable) {
    home.packages = [
      hyprSpecial
    ];

    wayland.windowManager.hyprland.settings.bind =
      lib.optional (lockExe != null) (
        mkBindWith "switch:Lid Switch" (execDispatcher (optionalExec lockExe)) { locked = true; }
      )
      ++ [
        (mkBindWith "XF86AudioRaiseVolume" (execDispatcher "${ipc} volume increase") { locked = true; })
        (mkBindWith "XF86AudioLowerVolume" (execDispatcher "${ipc} volume decrease") { locked = true; })
        (mkBindWith "XF86AudioMute" (execDispatcher "${ipc} volume muteOutput") { locked = true; })
      ]
      ++ lib.optionals isLaptop [
        (mkBindWith "XF86MonBrightnessUp" (execDispatcher "${ipc} brightness increase") { locked = true; })
        (mkBindWith "XF86MonBrightnessDown" (execDispatcher "${ipc} brightness decrease") {
          locked = true;
        })
      ]
      ++ [
        (mkBindWith "${mod} + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (mkBindWith "${mod} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
        (mkBind "${mod} + SHIFT + code:53" (execDispatcher "uwsm stop"))
        (mkBind "${mod} + code:42" (execDispatcher "hyprctl switchxkblayout all next"))
        (mkBind "SUPER + Tab" "hl.dsp.window.swap({ next = true })")
        (mkBind "ALT + Tab" "hl.dsp.window.cycle_next()")
        (mkBind "CTRL + Tab" (focusWorkspaceDispatcher "e+1"))
        (mkBind "${mod} + mouse_down" (focusWorkspaceDispatcher "e+1"))
        (mkBind "${mod} + mouse_up" (focusWorkspaceDispatcher "e-1"))
        (mkBind "${mod} + left" ''hl.dsp.focus({ direction = "left" })'')
        (mkBind "${mod} + right" ''hl.dsp.focus({ direction = "right" })'')
        (mkBind "${mod} + up" ''hl.dsp.focus({ direction = "up" })'')
        (mkBind "${mod} + down" ''hl.dsp.focus({ direction = "down" })'')
        (mkBind "${mod} + code:25" (execDispatcher "${ipc} launcher toggle"))
        (mkBind "${mod} + SHIFT + code:25" (execDispatcher "${ipc} controlCenter toggle"))
        (mkBind "${mod} + code:48" "hl.dsp.window.fullscreen()")
        (mkBind "${mod} + code:38" "hl.dsp.window.close()")
        (mkBind "${mod} + SHIFT + code:48" "hl.dsp.window.float()")
        (mkBind "${mod} + SHIFT + return" (execDispatcher (uexec terminalExe)))
        (mkBind "${mod} + CTRL + return" (execDispatcher (uexec "${terminalExe} --class floating")))
        (mkBind "${mod} + return" (specialAppDispatcher "scratch" "${terminalExe} --class scratchpad"))
        (mkBind "XF86AudioPlay" (execDispatcher "playerctl play-pause"))
        (mkBind "XF86AudioNext" (execDispatcher "playerctl next"))
        (mkBind "XF86AudioPrev" (execDispatcher "playerctl previous"))
        (mkBind "XF86AudioStop" (execDispatcher "playerctl stop"))
      ]
      ++ lib.optional (lockExe != null) (
        mkBind "${mod} + SHIFT + code:46" (execDispatcher (optionalExec lockExe))
      )
      ++ lib.optional (browserExe != null) (
        mkBind "${mod} + code:47" (execDispatcher (optionalExec browserExe))
      )
      ++ lib.optional (browserExe != null) (
        mkBind "${mod} + SHIFT + code:47" (
          execDispatcher (optionalExec (lib.concatStringsSep " " ([ browserExe ] ++ browserCfg.privateArgs)))
        )
      )
      ++ lib.optional (fileManagerExe != null) (
        mkBind "${mod} + code:40" (execDispatcher (uexec fileManagerExe))
      )
      ++ lib.optional (notesExe != null) (
        mkBind "${mod} + code:26" (execDispatcher (hyprSpecialExec "notes" "obsidian" notesExe))
      )
      ++ lib.optional (obsExe != null) (
        mkBind "${mod} + code:29" (execDispatcher (hyprSpecialExec "obs" "obs" obsExe))
      )
      ++ lib.optional (bitwardenExe != null) (
        mkBind "${mod} + code:57" (execDispatcher (hyprSpecialExec "secrets" "bitwarden" bitwardenExe))
      )
      ++ lib.optional (musicExe != null) (
        mkBind "${mod} + code:43" (execDispatcher (hyprSpecialExec "music" "tidal-hifi" musicExe))
      )
      ++ [
        (mkBind "${mod} + code:39" ''hl.dsp.workspace.toggle_special("messenger")'')
      ]
      ++ lib.optional clipboardCfg.enable (
        mkBind "${mod} + code:55" (execDispatcher (lib.getExe clipboardPicker))
      )
      ++ lib.optional screenshotsCfg.enable (
        mkBind "Print" (execDispatcher "${lib.getExe screenshotTool} full")
      )
      ++ lib.optional screenshotsCfg.enable (
        mkBind "SHIFT + Print" (execDispatcher "${lib.getExe screenshotTool} region")
      )
      ++ lib.optional (screenshotsCfg.enable && screenshotsCfg.annotationTool != "") (
        mkBind "CTRL + Print" (execDispatcher "${lib.getExe screenshotTool} region-annotate")
      )
      ++ workspaceBindings;
  };
}
