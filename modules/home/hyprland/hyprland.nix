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
      if [ ! -f "/persist/home/$USER/.config/hypr/monitors.conf" ]; then
        mkdir -p "/persist/home/$USER/.config/hypr"
        cat > "/persist/home/$USER/.config/hypr/monitors.conf" <<'EOF'
      # Default Hyprland monitor configuration
      # This uses the first detected monitor with preferred resolution
      # If you have issues with mouse boundaries, run: hyprctl monitors
      # Then update this file with the correct monitor configuration
      monitor = , preferred, auto, 1
      EOF
      fi

      if [ ! -f "/persist/home/$USER/.config/hypr/workspaces.conf" ]; then
        mkdir -p "/persist/home/$USER/.config/hypr"
        touch "/persist/home/$USER/.config/hypr/workspaces.conf"
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
      package = null;
      portalPackage = null;

      settings = {
        source = [
          "~/.config/hypr/monitors.conf"
          "~/.config/hypr/workspaces.conf"
        ];

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

        device = [
          {
            name = "yubico-yubikey-otp+fido+ccid";
            kb_layout = "us";
            kb_variant = "";
            kb_options = "";
          }
        ];

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

        opengl = { };
        render = { };
        experimental = { };
        debug = { };
      };
    };
  };
}
