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
  terminalPackage = qconfig.desktop.terminal.package or pkgs.kitty;
  terminalExe = lib.getExe terminalPackage;

  workspaces = [
    { num = "1"; code = "58"; }
    { num = "2"; code = "59"; }
    { num = "3"; code = "60"; }
    { num = "4"; code = "44"; }
    { num = "5"; code = "45"; }
    { num = "6"; code = "46"; }
    { num = "7"; code = "30"; }
    { num = "8"; code = "31"; }
    { num = "9"; code = "32"; }
    { num = "10"; code = "65"; }
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
    wayland.windowManager.hyprland.settings = {
      "$mod" = if isVm then "ALT" else "super";

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bind = [
        "$mod SHIFT, code:53, exec, uwsm stop"
        "$mod, code:42, exec, hyprctl switchxkblayout all next"
        "super, Tab, swapnext"
        "ALT, Tab, cyclenext"
        "CTRL, Tab, workspace, e+1"
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, code:48, fullscreen"
        "$mod, code:38, killactive"
        "$mod SHIFT, code:48, togglefloating"
        "$mod SHIFT, return, exec, uwsm app -- ${terminalExe}"
        "$mod CTRL, return, exec, uwsm app -- ${terminalExe} --class floating"
      ] ++ workspaceBindings;
    };
  };
}
