{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [
    "desktop.hyprland"
    "desktop.hyprland.special-workspaces"
    "desktop.terminal"
  ];

  options =
    { lib, ... }:
    {
      additionalKeybinds = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              key = lib.mkOption {
                type = lib.types.str;
                description = "Key combination in Hyprland Lua syntax.";
              };
              dispatcher = lib.mkOption {
                type = lib.types.str;
                description = "Lua dispatcher expression, such as hl.dsp.window.close().";
              };
              options = lib.mkOption {
                type = lib.types.attrs;
                default = { };
                description = "Optional native Hyprland bind options.";
              };
            };
          }
        );
        default = [ ];
        description = "Additional native Hyprland Lua key bindings.";
      };
    };

  home =
    {
      config,
      context,
      cfg,
      lib,
      ...
    }:
    let
      terminal =
        if (context.vm or false) || !config.programs.foot.server.enable then "foot" else "footclient";
      lua = lib.generators.toLua { };
      inline = lib.generators.mkLuaInline;
      modKey = key: inline ''mod .. " + ${key}"'';
      mkBind = key: dispatcher: options: {
        _args = [
          key
          (inline dispatcher)
        ]
        ++ lib.optional (options != { }) options;
      };
      mkModBind =
        key: dispatcher: options:
        mkBind (modKey key) dispatcher options;
      exec = command: "hl.dsp.exec_cmd(${lua command})";
      focusWorkspace = workspace: "hl.dsp.focus({ workspace = ${lua workspace} })";
      moveWorkspace =
        workspace: follow:
        "hl.dsp.window.move({ workspace = ${lua workspace}, follow = ${
          if follow then "true" else "false"
        } })";
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
      visibleWorkspace = workspace: if workspace == "10" then "0" else workspace;
      workspaceBinds = builtins.concatLists (
        map (
          workspace:
          let
            visible = visibleWorkspace workspace.num;
          in
          [
            (mkModBind visible (focusWorkspace visible) { })
            (mkModBind "code:${workspace.code}" (focusWorkspace workspace.num) { })
            (mkModBind "SHIFT + CTRL + ${visible}" (moveWorkspace visible true) { })
            (mkModBind "SHIFT + CTRL + code:${workspace.code}" (moveWorkspace workspace.num true) { })
            (mkModBind "CTRL + ${visible}" (moveWorkspace visible false) { })
            (mkModBind "CTRL + code:${workspace.code}" (moveWorkspace workspace.num false) { })
          ]
        ) workspaces
      );
      additionalBinds = map (
        binding: mkBind binding.key binding.dispatcher binding.options
      ) cfg.additionalKeybinds;
    in
    {
      wayland.windowManager.hyprland.settings = {
        mod._var = if context.vm or false then "ALT" else "SUPER";

        bind = [
          (mkBind "switch:Lid Switch" (exec "uwsm app -- hyprlock") { locked = true; })
          (mkBind "XF86AudioRaiseVolume" (exec "pamixer -i 5") { locked = true; })
          (mkBind "XF86AudioLowerVolume" (exec "pamixer -d 5") { locked = true; })
          (mkBind "XF86AudioMute" (exec "pamixer -t") { locked = true; })
          (mkBind "XF86AudioPlay" (exec "playerctl play-pause") { locked = true; })
          (mkBind "XF86AudioNext" (exec "playerctl next") { locked = true; })
          (mkBind "XF86AudioPrev" (exec "playerctl previous") { locked = true; })
          (mkBind "XF86AudioStop" (exec "playerctl stop") { locked = true; })
          (mkModBind "mouse:272" "hl.dsp.window.drag()" { mouse = true; })
          (mkModBind "mouse:273" "hl.dsp.window.resize()" { mouse = true; })
          (mkModBind "return" (exec "uwsm app -- ${terminal}") { })
          (mkModBind "SHIFT + return" (exec "uwsm app -- ${terminal}") { })
          (mkModBind "CTRL + return" (exec "uwsm app -- ${terminal} --app-id floating") { })
          (mkModBind "SHIFT + code:53" (exec "uwsm stop") { })
          (mkModBind "SHIFT + code:26" (exec "hyprctl reload") { })
          (mkModBind "code:42" (exec "hyprctl switchxkblayout all next") { })
          (mkModBind "mouse_down" (focusWorkspace "e+1") { })
          (mkModBind "mouse_up" (focusWorkspace "e-1") { })
          (mkModBind "code:48" "hl.dsp.window.fullscreen()" { })
          (mkModBind "code:38" "hl.dsp.window.close()" { })
          (mkModBind "SHIFT + code:48" ''hl.dsp.window.float({ action = "toggle" })'' { })
          (mkModBind "code:61" ''hl.dsp.layout("togglesplit")'' { })
          (mkModBind "left" ''hl.dsp.focus({ direction = "left" })'' { })
          (mkModBind "right" ''hl.dsp.focus({ direction = "right" })'' { })
          (mkModBind "up" ''hl.dsp.focus({ direction = "up" })'' { })
          (mkModBind "down" ''hl.dsp.focus({ direction = "down" })'' { })
          (mkModBind "code:47" (exec "uwsm app -- brave-origin") { })
          (mkModBind "CTRL + code:47" (exec "uwsm app -- brave-origin --private-window") { })
          (mkModBind "code:25" (exec "uwsm app -- rofi -show drun") { })
          (mkModBind "code:29" (exec "hypr-special recording obs -- obs") { })
          (mkModBind "code:40" (exec "uwsm app -- ${terminal} -e yazi") { })
          (mkModBind "code:57" (exec "hypr-special secrets Bitwarden -- bitwarden") { })
          (mkModBind "code:26" (exec "hypr-special notes obsidian -- obsidian") { })
          (mkModBind "code:39" ''hl.dsp.workspace.toggle_special("messenger")'' { })
          (mkBind "SUPER + Tab" "hl.dsp.window.swap({ next = true })" { })
          (mkBind "ALT + Tab" "hl.dsp.window.cycle_next()" { })
          (mkBind "CTRL + Tab" (focusWorkspace "e+1") { })
        ]
        ++ workspaceBinds
        ++ additionalBinds;
      };
    };
}
