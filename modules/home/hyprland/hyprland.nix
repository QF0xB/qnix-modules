{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  pkgs,
  ...
}: let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg =
    if lib.hasAttrByPath ["desktop" "hyprland"] qconfig
    then qconfig.desktop.hyprland
    else {enable = false;};

  xkbConfig =
    if lib.hasAttrByPath ["system" "localisation" "xkb"] qconfig
    then qconfig.system.localisation.xkb
    else null;
  isVm =
    if lib.hasAttrByPath ["status" "vm"] qconfig
    then qconfig.status.vm
    else false;
  performanceMode = !isVm;
in {
  config = lib.mkIf cfg.enable {
    home.activation.createHyprMonitorConf = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f "/persist/home/$USER/.config/hypr/monitors.lua" ]; then
        mkdir -p "/persist/home/$USER/.config/hypr"
        cat > "/persist/home/$USER/.config/hypr/monitors.lua" <<'EOF'
      -- Default Hyprland monitor configuration
      -- This uses the first detected monitor with preferred resolution.
      -- If you have issues with mouse boundaries, run: hyprctl monitors
      -- Then update this file with the correct monitor configuration.
      hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = "1",
      })
      EOF
      fi

      if [ ! -f "/persist/home/$USER/.config/hypr/workspaces.lua" ]; then
        mkdir -p "/persist/home/$USER/.config/hypr"
        touch "/persist/home/$USER/.config/hypr/workspaces.lua"
      fi
    '';

    home.packages = with pkgs; [
      wl-clipboard
    ];

    home.sessionVariables = lib.optionalAttrs (cfg.noHardwareCursors || isVm) {
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      package = null;
      portalPackage = null;

      # Hyprland 0.55 introduced native Lua configuration, but Home Manager's
      # generic settings -> Lua conversion is not compatible with legacy
      # keyword-style settings such as bind/windowrule/gesture/exec-once.
      # Keep qnix on the supported legacy parser until these modules are
      # migrated to the native Lua API deliberately.
      configType = "hyprlang";

      # UWSM owns graphical-session.target and the session environment. The
      # Home Manager Hyprland systemd integration conflicts with UWSM.
      systemd.enable = false;

      settings = {
        source = [
          "~/.config/hypr/monitors.conf"
          "~/.config/hypr/workspaces.conf"
        ];

        general = {
          border_size = 2;
          gaps_in = 5;
          gaps_out = 20;
          layout = "dwindle";
          resize_on_border = true;
          snap.enabled = true;
        };

        config = {
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

          misc = {
            disable_hyprland_logo = true;
            focus_on_activate = true;
            vrr =
              if isVm
              then 0
              else 1;
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

          opengl = {};
          render = {};
          experimental = {};
          debug = {};
        };

        device = [
          {
            name = "yubico-yubikey-otp+fido+ccid";
            kb_layout = "us";
            kb_variant = "";
            kb_options = "";
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
            mods =
              if isVm
              then "ALT"
              else "SUPER";
            action = "float";
          }
        ];
      };
    };
  };
}
