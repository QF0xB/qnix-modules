{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires = {
    nixos = [ "desktop.wayland" ];
    home = [
      "desktop.wayland"
      "system.localisation"
    ];
  };

  options =
    {
      context,
      lib,
      ...
    }:
    {
      gapsIn = lib.mkOption {
        type = lib.types.number;
        default = 5;
        description = "Inner gaps between Hyprland windows.";
      };

      gapsOut = lib.mkOption {
        type = lib.types.number;
        default = 20;
        description = "Outer gaps between Hyprland windows and the monitor edge.";
      };

      allowTearing = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether Hyprland may use tearing for individual windows.";
      };

      animations = lib.mkOption {
        type = lib.types.bool;
        default = !(context.vm or false);
        description = "Whether Hyprland animations are enabled.";
      };

      vrr = lib.mkOption {
        type = lib.types.ints.between 0 2;
        default = 1;
        description = "Hyprland variable refresh rate mode.";
      };

      swallowRegex = lib.mkOption {
        type = lib.types.str;
        default = "'^(foot)$'";
        description = "Regular expression for terminal windows that may be swallowed.";
      };

      noHardwareCursors = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to disable hardware cursors for Hyprland.";
      };

      devices = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { ... }:
            {
              options = {
                sensitivity = lib.mkOption {
                  type = lib.types.nullOr lib.types.number;
                  default = null;
                  description = "Pointer sensitivity override for this device.";
                };

                kbLayout = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Keyboard layout override for this device.";
                };

                kbVariant = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Keyboard variant override for this device.";
                };

                kbOptions = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Keyboard options override for this device.";
                };
              };
            }
          )
        );
        default = { };
        description = "Hyprland per-device input overrides.";
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
      qnix,
      ...
    }:
    let
      modifier = if context.vm or false then "ALT" else "super";
    in
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
          workspace_rule = [
            {
              workspace = "s[true]";
              gaps_out = 80;
              gaps_in = 20;
            }
          ];

          animation = [
            {
              leaf = "specialWorkspace";
              enabled = true;
              speed = 8;
              bezier = "default";
              style = "slidevert";
            }
          ];

          config = {
            general = {
              gaps_in = cfg.gapsIn;
              gaps_out = cfg.gapsOut;
              border_size = 2;
              layout = "dwindle";
              resize_on_border = true;
              allow_tearing = cfg.allowTearing;
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
              enabled = cfg.animations;
              workspace_wraparound = true;
            };

            cursor = {
              no_hardware_cursors = cfg.noHardwareCursors;
              persistent_warps = true;
            };

            input = {
              kb_layout = qnix.system.localisation.xkb.layout;
              kb_variant = qnix.system.localisation.xkb.variant;
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

            gestures.workspace_swipe_forever = true;

            misc = {
              force_default_wallpaper = 0;
              disable_splash_rendering = true;
              vfr = true;
              vrr = cfg.vrr;
              enable_swallow = true;
              swallow_regex = cfg.swallowRegex;
              focus_on_activate = true;
            };

            debug.disable_logs = false;
            ecosystem = {
              no_update_news = true;
              no_donation_nag = true;
            };
          };

          gesture = [
            {
              fingers = 4;
              direction = "horizontal";
              action = "workspace";
            }
            {
              fingers = 4;
              direction = "up";
              scale = 1.5;
              action = "fullscreen";
            }
            {
              fingers = 4;
              direction = "down";
              action = "close";
            }
            {
              fingers = 2;
              direction = "pinch";
              action = "resize";
            }
            {
              fingers = 2;
              direction = "pinch";
              mods = modifier;
              action = "float";
            }
          ];

          device = lib.mapAttrsToList (
            name: device:
            {
              inherit name;
            }
            // lib.optionalAttrs (device.sensitivity != null) {
              sensitivity = device.sensitivity;
            }
            // lib.optionalAttrs (device.kbLayout != null) {
              kb_layout = device.kbLayout;
            }
            // lib.optionalAttrs (device.kbVariant != null) {
              kb_variant = device.kbVariant;
            }
            // lib.optionalAttrs (device.kbOptions != null) {
              kb_options = device.kbOptions;
            }
          ) cfg.devices;

          on = [
            {
              _args = [
                "hyprland.start"
                (lib.generators.mkLuaInline ''
                  function()
                    hl.exec_cmd("hyprctl switchxkblayout all 1")
                    hl.exec_cmd("systemctl --user start hyprpolkitagent")
                  end
                '')
              ];
            }
          ]
          ++ lib.optional (context.laptop or false) {
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline ''
                function()
                  hl.exec_cmd("light -I")
                end
              '')
            ];
          };
        };
      };
    };
}
