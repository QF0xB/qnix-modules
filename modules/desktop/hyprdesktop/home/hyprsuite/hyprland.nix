{
  config,
  osConfig,
  lib,
  pkgs,
  isVm,
  isLaptop,
  ...
}:

let
  cfg = osConfig.qnix.desktop.hyprdesktop;

  keyboards = osConfig.qnix.core.localisation.xkb;
  apps = osConfig.qnix.apps;

  uexec = program: "exec, uwsm app -- ${program} ";
  default-app-uexec = app-name: (uexec (lib.getExe apps.${app-name}));

  vm-performance = if isVm then false else true;
in
{
  imports = [
    ./monitors-workspaces.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpolkitagent
    ];

    home.sessionVariables.NIXOS_OZONE_WL = "1";

    wayland.windowManager.hyprland = {
      enable = true;

      # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
      package = null;
      portalPackage = null;

      settings = {
        source = [
          "~/.config/hypr/monitors.conf"
          "~/.config/hypr/workspaces.conf"
        ];

        general = {
          # Gaps
          border_size = 2;
          gaps_in = if isLaptop then "3" else "5"; # Between tiles
          gaps_out = if isLaptop then "12" else "20"; # To screen edges

          layout = "dwindle";
          resize_on_border = true; # Allow resizing by dragging borders.

          snap = {
            # Snapping to sides like on windows etc
            enabled = true;
          };
        };

        decoration = {
          rounding = "10"; # In pixels

          # Blur and shadow enabled by default
          blur = {
            enabled = vm-performance; # No blur in vm to help performance
          };

          shadow = {
            enabled = vm-performance; # no shadow in vm to help performance
          };
        };

        device = [
          {
            name = "yubico-yubikey-otp+fido+ccid";
            kb_layout = "us"; # Use US layout for this device
            kb_variant = "";
            kb_options = "";
          }
        ];

        animations = {
          enabled = vm-performance; # No animations in vm to help performance
        };

        input = {
          kb_layout = keyboards.layout;
          kb_variant = keyboards.variant;

          scroll_method = "2fg"; # two-finger scroll

          touchpad = {
            clickfinger_behavior = true;

            drag_3fg = "1"; # three-finger drag
          };
        };

        gestures = {
          gesture = [
            "4, horizontal, workspace" # Workspace switch with left/right
            "4, up, scale: 1.5, fullscreen" # Fullscreen with up
            "4, down, close" # Close on down
            "2, pinch, resize" # Resize on 2fg
            "2, pinch, mod: $mod, float" # Float on 2fg with mod
          ];
        };

        misc = {
          disable_hyprland_logo = true;
          vrr = "1";
          focus_on_activate = true; # Focus window when requesting activation
          anr_missed_pings = "10"; # Increase default for not responding to prevent issues
        };

        xwayland = {
          force_zero_scaling = true; # Fractional scaling is brken in XWayland
        };

        opengl = {

        };

        render = {

        };

        cursor = {
          persistent_warps = true; # Move to last position on window
        };

        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };

        experimantal = {

        };

        debug = {

        };

        # All letters written here are in qwertz
        "$mod" = if isVm then "ALT" else "super";
        bindl = [
          # Locked binds (lockscreen etc)
          ",switch:Lid Switch, ${uexec ''hyprlock''}" # Lock when lid closed.
        ];
        bindm = [
          # Mouse binds
          # Move window with Mouse + MOD
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        bind = [
          #
          #  Hyprland behaviour
          #
          "$mod SHIFT, code:53, exec, uwsm stop #x" # Stop hyprland with MOD+SHIFT+X
          "$mod, code:42, exec, hyprctl switchxkblayout all next #g" # Switch keyboard layout with MOD+G

          #
          #  Switching
          #
          "super, Tab, swapnext" # Swap with next window
          "ALT, Tab, cyclenext" # focus next window
          "CTRL, Tab, workspace, e+1" # go to next workspace

          # Mouse scroll
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          # Move focus with arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          #
          #  Windows
          #
          "$mod, code:48, fullscreen #ä" # Fullscreen window with MOD+Ä
          "$mod, code:38, killactive #a" # Kill focused window with MOD+A
          "$mod SHIFT, code:48, togglefloating #f" # Float focused window with MOD+SHIFT+F

          #
          #  Programs
          #

          # Shell
          "$mod, return, ${default-app-uexec ''terminal''}" # Start terminal normally
          "$mod CTRL, return, ${default-app-uexec ''terminal''} --class floating" # Start floating terminal

          # Browser
          "$mod, code:47, ${default-app-uexec ''browser''} #Ö" # Start browser normally with MOD+Ö
          "$mod SHIFT, code:47, ${default-app-uexec ''browser''} --private-window #Ö" # Start browser in private mode with MOD+SHIFT+Ö

          # Application manager
          # "$mod, code:25, ${uexec ''rofi -show drun -config ~/.config/rofi/launchers/type-${cfg.rofi.launcher.theme.type}/style-${cfg.rofi.launcher.theme.style}.rasi -run-command "uwsm app -- {cmd}"''} #w" # Program starter with MOD+W

          # Filemanager (not used much, using yazi now. Might change)
          "$mod, code:40, ${default-app-uexec ''file-manager''} #d" # Start file-manager with MOD+D

          # Note taking
          "$mod, code:26, ${default-app-uexec ''notes''} #e" # Start notetaking app with MOD+E

          # AGS bar (sliding bar + hot reload)
          "$mod, Tab, exec, ags -r \"toggleBar()\"" # Toggle sliding bar on the focused monitor
          "$mod SHIFT, Tab, exec, ags -r \"reload()\"" # Hot reload AGS config

          # audio/sound control
          ", xf86audioraisevolume, exec, pamixer -i 5 && dunstify -h int:value:'$(pamixer --get-volume)' -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 'Volume: $(pamixer --get-volume) %'"
          ", xf86audiolowervolume, exec, pamixer -d 5 && dunstify -h int:value:'$(pamixer --get-volume)' -i ~/.config/dunst/assets/volume.svg -t 500 -r 2593 'Volume: $(pamixer --get-volume) %'"
          ", xf86AudioMute, exec, pamixer -t && dunstify -i ~/.config/dunst/assets/$(pamixer --get-mute | grep -q 'true' && echo 'volume-mute.svg' || echo 'volume.svg') -t 500 -r 2593 'Toggle Mute'"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86audiostop, exec, playerctl stop"

        ]
        ++ (
          let
            # Define workspaces as a list of records.
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

            # When displaying a workspace key we want "10" to be shown as "0".
            conv = ws: if ws == "10" then "0" else ws;

            # generateBindings takes one workspace record and returns a list of six binding lines.
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

            # bindingLines is the concatenation of all binding lists.
            bindingLines = builtins.concatLists (map generateBindings workspaces);
          in
          bindingLines
        );
      };
    };
  };
}
