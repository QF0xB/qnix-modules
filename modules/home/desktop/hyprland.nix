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
  cfg =
    if lib.hasAttrByPath [ "desktop" "hyprland" ] qconfig then
      qconfig.desktop.hyprland
    else
      { enable = false; };

  xkbConfig =
    if lib.hasAttrByPath [ "system" "localisation" "xkb" ] qconfig then
      qconfig.system.localisation.xkb
    else
      null;
  isVm = if lib.hasAttrByPath [ "status" "vm" ] qconfig then qconfig.status.vm else false;
  performanceMode = !isVm;

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
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpolkitagent
    ];

    home.sessionVariables = lib.optionalAttrs (cfg.noHardwareCursors || isVm) {
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;

      settings = lib.mkMerge [
        {
          exec-once = [
            "systemctl --user start hyprpolkitagent"
          ];

          general = {
            border_size = 2;
            gaps_in = 5;
            gaps_out = 20;
            layout = "dwindle";
            resize_on_border = true;
            snap.enabled = true;
          };

          decoration = {
            rounding = 10;
            blur.enabled = performanceMode;
            shadow.enabled = performanceMode;
          };

          animations.enabled = performanceMode;

          input =
            (lib.optionalAttrs (xkbConfig != null) {
              kb_layout = xkbConfig.layout;
              kb_variant = xkbConfig.variant;
            })
            // {
              scroll_method = "2fg";
              touchpad = {
                clickfinger_behavior = true;
                drag_3fg = 1;
              };
            };

          gestures.gesture = [
            "4, horizontal, workspace"
            "4, up, scale: 1.5, fullscreen"
            "4, down, close"
            "2, pinch, resize"
            "2, pinch, mod: $mod, float"
          ];

          misc = {
            disable_hyprland_logo = true;
            focus_on_activate = true;
            vrr = if isVm then 0 else 1;
            anr_missed_pings = 10;
          };

          xwayland.force_zero_scaling = true;

          cursor = {
            no_hardware_cursors = cfg.noHardwareCursors;
            persistent_warps = true;
          };

          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };
        }

        (lib.mkIf cfg.setDefaultKeybinds {
          "$mod" = if isVm then "ALT" else "SUPER";

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
          ]
          ++ workspaceBindings;
        })

        (lib.mkIf cfg.setDefaultWindowRules {
          windowrule = [
            "match:modal true, float on, center on, dim_around on, stay_focused on"
            "match:title ^(Open File|Save File|Choose File|File Upload|Open|Save As).*$, float on"
            "match:title ^(Authentication Required|Permission required).*$, float on, center on, stay_focused on"
            "match:class ^(pinentry-|gcr-prompter).*$, stay_focused on"
            "match:class ^(pinentry-|gcr-prompter).*$, float on, center on, dim_around on"
            "match:title ^(Picture-in-Picture|Picture in picture)$, float on, pin on, keep_aspect_ratio on, no_blur on, no_shadow on, size 30% 30%, move (monitor_w-(window_w+21)) 58"
            "match:class ^(qalculate-gtk|org.gnome.Calculator)$, float on, center on, size 520 620"
            "match:class ^(org\\.pulseaudio\\.)?pavucontrol$, float on, center on, size 900 650"
            "match:class ^\\.?blueman-manager(-wrapped)?$, float on, center on, size 900 650"
            "match:class ^(nm-connection-editor)$, float on, center on, size 900 650"
            "match:class ^steam$, match:title ^(Friends List|Steam Friends List).*$, float on, size 420 900, move (monitor_w-(window_w+24)) (monitor_h*0.12), focus_on_activate off"
            "match:class ^(ghostty|footclient|kitty|Alacritty)$, tag +term"
            "match:class ^(code|cursor|codium|jetbrains-.*)$, match:float false, tag +code"
            "match:class ^(brave-browser|google-chrome)$, tag +browser"
            "match:class ^(tidal-hifi)$, tag +music"
            "match:class ^(nemo|thunar)$, tag +files"
            "match:class ^(Bitwarden)$, tag +passwords"
            "match:class ^(signal|discord)$, tag +messenger"
            "match:class ^(obsidian)$, tag +notes"
            "match:class ^(obs|com\\.obsproject\\.Studio)$, tag +obs"
            "match:class ^Bitwarden$, no_screen_share on"
            "match:class ^(pinentry-|gcr-prompter).*$, no_screen_share on"
            "match:tag code, workspace 1"
            "match:tag term, workspace 2"
            "match:tag browser, workspace 3"
            "match:tag files, workspace 9"
            "match:tag music, workspace special:music"
            "match:class ^(scratchpad)$, workspace special:scratch"
            "match:tag messenger, workspace special:messenger"
            "match:tag notes, workspace special:notes"
            "match:tag obs, workspace special:obs"
            "match:tag passwords, workspace special:secrets"
          ];
        })

        (lib.mkIf cfg.setDefaultSpecialWorkspace {
          workspace = [ "s[true], gapsout:80, gapsin:20" ];

          decoration = {
            dim_special = 0.7;
            blur.special = performanceMode;
          };

          animations = {
            enabled = performanceMode;
            workspace_wraparound = false;
            animation = [ "specialWorkspace, 1, 8, default, slidevert" ];
          };
        })
      ];
    };
  };
}
