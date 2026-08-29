{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires = {
    nixos = [ "desktop.wayland" ];
    home = [ "desktop.hyprland" ];
  };

  options =
    { lib, ... }:
    {
      background = lib.mkOption {
        type = lib.types.oneOf [
          lib.types.str
          lib.types.path
        ];
        default = ../../old/assets/wallpapers/solarized-dark.png;
        description = "Hyprlock background path; 'screenshot' uses the current screen.";
      };

      showClock = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to show the current time on the lock screen.";
      };

      showDate = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to show the current date on the lock screen.";
      };

      blur = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to blur the Hyprlock background.";
      };
    };

  nixos =
    { ... }:
    {
      security.pam.services.hyprlock = { };
    };

  home =
    {
      cfg,
      lib,
      ...
    }:
    {
      programs.hyprlock = {
        enable = true;
        settings = {
          background = lib.mkForce [
            (
              {
                path = toString cfg.background;
                noise = 0.0117;
                contrast = 0.8916;
                brightness = 0.8172;
                vibrancy = 0.1696;
                vibrancy_darkness = 0;
              }
              // lib.optionalAttrs cfg.blur {
                blur_passes = 3;
                blur_size = 8;
              }
            )
          ];

          general = {
            hide_cursor = true;
            grace = 0;
            no_fade_in = false;
            no_fade_out = false;
          };

          input-field = lib.mkForce [
            {
              size = "250, 50";
              position = "0, -80";
              halign = "center";
              valign = "center";
              outline_thickness = 2;
              dots_size = 0.2;
              dots_spacing = 0.2;
              dots_center = true;
              outer_color = "rgba(8fbcbbff)";
              inner_color = "rgba(2e3440cc)";
              font_color = "rgba(d8dee9ff)";
              fade_on_empty = false;
              placeholder_text = "<i>Input password...</i>";
              hide_input = false;
              rounding = 10;
              check_color = "rgba(88c0d0ff)";
              fail_color = "rgba(bf616aff)";
              fail_text = "<i>$FAIL</i>";
            }
          ];

          label = lib.mkForce (
            lib.optional cfg.showClock {
              text = "$TIME";
              font_size = 96;
              font_family = "Fira Sans";
              color = "rgba(eceff4ff)";
              position = "0, 160";
              halign = "center";
              valign = "center";
            }
            ++ lib.optional cfg.showDate {
              text = ''cmd[update:60000] echo "$(date '+%A, %d %B %Y')"'';
              font_size = 20;
              font_family = "Fira Sans";
              color = "rgba(d8dee9ff)";
              position = "0, 80";
              halign = "center";
              valign = "center";
            }
          );
        };
      };
    };
}
