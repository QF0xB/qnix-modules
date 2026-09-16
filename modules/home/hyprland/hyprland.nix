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
in
{
  config = lib.mkIf cfg.enable {
    home.activation.createHyprMonitorConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.config/hypr/monitors.lua" ]; then
        mkdir -p "$HOME/.config/hypr"
        cat > "$HOME/.config/hypr/monitors.lua" <<'EOF'
      -- Default Hyprland monitor configuration
      -- This uses the first detected monitor with preferred resolution.
      -- If you have issues with mouse boundaries, run: hyprctl monitors
      -- Then update this file with the correct monitor configuration.
      hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = 1,
      })
      EOF
      fi

      if [ ! -f "$HOME/.config/hypr/workspaces.lua" ]; then
        mkdir -p "$HOME/.config/hypr"
        touch "$HOME/.config/hypr/workspaces.lua"
      fi
    '';

    home.packages = with pkgs; [
      wl-clipboard
      hyprpolkitagent
    ];

    home.sessionVariables = lib.optionalAttrs (cfg.noHardwareCursors || isVm) {
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      package = null;
      portalPackage = null;

      # UWSM owns graphical-session.target and the session environment. The
      # Home Manager Hyprland systemd integration conflicts with UWSM.
      systemd.enable = false;

      # Keep monitor and workspace overrides in persistent Lua files.  This is
      # Home Manager's native Lua include mechanism; hl.source() is a legacy
      # Hyprlang API and is unavailable in Lua configurations.
      extraLuaFiles.userConfig.content = ''
        require("monitors")
        require("workspaces")
      '';

      settings = {
        config = {
          general = {
            border_size = 2;
            gaps_in = 5;
            gaps_out = 20;
            layout = "dwindle";
            resize_on_border = true;
            allow_tearing = false;
          };

          decoration = {
            rounding = 10;
            dim_special = 0.7;
            blur = {
              enabled = performanceMode;
              special = performanceMode;
              size = 10;
              passes = 1;
              new_optimizations = true;
            };
          };

          animations = {
            enabled = performanceMode;
            workspace_wraparound = true;
          };

          input =
            (lib.optionalAttrs (xkbConfig != null) {
              kb_layout = xkbConfig.layout;
              kb_variant = xkbConfig.variant;
            })
            // {
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
            focus_on_activate = true;
            vrr = if isVm then 0 else 1;
            enable_swallow = true;
            swallow_regex = "'^(foot)$'";
          };

          cursor = {
            no_hardware_cursors = cfg.noHardwareCursors;
            persistent_warps = true;
          };

          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

          debug = {
            disable_logs = false;
            vfr = true;
          };
        };

        device = [
          {
            name = "yubico-yubikey-otp+fido+ccid";
            kb_layout = "us";
            kb_variant = "";
            kb_options = "";
          }
        ];

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
        ];

        gesture = [
          {
            fingers = 4;
            direction = "horizontal";
            action = "workspace";
          }
          {
            fingers = 4;
            direction = "up";
            action = "fullscreen";
            scale = 1.5;
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
            mods = if isVm then "ALT" else "SUPER";
            action = "float";
          }
        ];
      };
    };
  };
}
