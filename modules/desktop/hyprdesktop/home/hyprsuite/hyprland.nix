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
  performance-mode = if isVm then false else true;
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

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    }
    // lib.optionalAttrs isVm {
      # VM sessions often lag/jitter with hardware cursors.
      WLR_NO_HARDWARE_CURSORS = "1";
    };

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

        exec-once = [
          "systemctl --user start hyprpolkitagent"
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
            enabled = performance-mode; # No blur in vm to help performance
          };

          shadow = {
            enabled = performance-mode; # no shadow in vm to help performance
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
          enabled = performance-mode; # No animations in vm to help performance
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
          vrr = if isVm then "0" else "1";
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
      };
    };
  };
}
