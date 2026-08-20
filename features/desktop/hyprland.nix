{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires = {
    nixos = [ "desktop.wayland" ];
    home = [ "desktop.wayland" ];
  };

  options =
    { lib, ... }:
    {
      noHardwareCursors = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to disable hardware cursors for Hyprland.";
      };
    };

  nixos =
    {
      pkgs,
      ...
    }:
    {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        package = pkgs.hyprland;
        portalPackage = pkgs.xdg-desktop-portal-hyprland;
      };

      programs.uwsm.enable = true;

      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };

  home =
    {
      cfg,
      context,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        wl-clipboard
        hyprpolkitagent
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        systemd.enable = false;
        settings = {
          workspace = [
            "s[true], gapsout:80, gapsin:20"
          ];

          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            layout = "dwindle";
            resize_on_border = true;
            allow_tearing = false;
          };

          decoration = {
            rounding = 10;
            dim_special = 0.7;
            blur = {
              enabled = true;
              special = true;
              size = 10;
              passes = 1;
              new_optimizations = true;
            };
          };

          animations = {
            enabled = true;
            workspace_wraparound = true;
            animation = [
              "specialWorkspace, 1, 8, default, slidevert"
            ];
          };

          cursor = {
            no_hardware_cursors = cfg.noHardwareCursors;
            persistent_warps = true;
          };

          input = {
            kb_layout = "us,de";
            kb_variant = ",koy";
            kb_model = "";
            kb_rules = "";
            follow_mouse = 1;
            scroll_method = "2fg";
            force_no_accel = true;
            sensitivity = 0;
            touchpad = {
              natural_scroll = false;
              clickfinger_behavior = true;
            };
          };

          gestures = {
            workspace_swipe_forever = true;
            gestures = {
              gesture = [
                "4, horizontal, workspace"
                "4, up, scale: 1.5, fullscreen"
                "4, down, close"
                "2, pinch, resize"
                "2, pinch, mod: $mod, float"
              ];
            };
          };

          misc = {
            force_default_wallpaper = 0;
            disable_splash_rendering = true;
            vfr = true;
            vrr = 1;
            enable_swallow = true;
            swallow_regex = "'^(kitty)$'";
            focus_on_activate = true;
          };

          device = [
            {
              name = "epic-mouse-v1";
              sensitivity = -0.5;
            }
            {
              name = "yubico-yubikey-otp+fido+ccid";
              kb_layout = "us";
              kb_variant = "";
              kb_options = "";
            }
          ];

          debug.disable_logs = false;
          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

          exec = [ "hyprctl switchxkblayout all 1" ];
          exec-once = [
            "systemctl --user start hyprpolkitagent"
          ]
          ++ lib.optional (context.laptop or false) "light -I";
        };
      };
    };
}
