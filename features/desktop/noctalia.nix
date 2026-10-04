{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [
    "desktop.hyprland"
    "desktop.terminal"
  ];

  options =
    { lib, pkgs, ... }:
    {
      autostart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to start Noctalia through systemd with the graphical session.";
      };

      settings = lib.mkOption {
        type = (pkgs.formats.toml { }).type;
        default = { };
        description = "Overrides for Noctalia's upstream defaults, serialized as TOML by Home Manager.";
        example = {
          bar.main.position = "left";
          location.address = "Munich";
        };
      };
    };

  home =
    {
      cfg,
      context,
      lib,
      ...
    }:
    {
      home.file."Pictures/wallpaper/solarized-dark.png".source =
        ../../assets/wallpapers/solarized-dark.png;

      programs.noctalia = {
        enable = true;
        systemd.enable = cfg.autostart;
        settings = lib.mkMerge [
          {
            calendar = {
              enabled = true;
            };
            location = {
              auto_locate = true;
            };

            wallpaper = {
              directory = "/home/q.braendli/Pictures/wallpaper";
              transition = [ "honeycomb" ];
            };

            wallpaper.default = {
              path = "/home/q.braendli/Pictures/wallpaper/solarized-dark-with-mountain.png";
            };

            bar.default = {
              capsule = lib.mkDefault true;
              capsule_fill = lib.mkDefault "#073642";
              concave_edge_corners = lib.mkDefault false;
              margin_edge = lib.mkDefault 10;
              margin_ends = lib.mkDefault 20;
              position = lib.mkDefault "left";
              scale = lib.mkDefault 1.1000000089406967;
            };
            lockscreen = {
              enabled = lib.mkDefault true;
              lock_before_suspend = lib.mkDefault true;
            };

            shell = {
              external_ip_enabled = lib.mkDefault true;
              settings_window_translucent = lib.mkDefault true;
              polkit_agent = lib.mkDefault true;
            };

            shell.greeter_sync = {
              auto_sync = true;
            };

            shell.panel = {
              open_near_click_control_center = lib.mkDefault true;
            };

            notification = {
              follow_focused_output = lib.mkDefault true;
            };
          }
          (lib.mkIf (!(context.laptop or false)) {
            control_center.shortcuts = lib.mkDefault [
              { type = "wifi"; }
              { type = "bluetooth"; }
              { type = "caffeine"; }
              { type = "nightlight"; }
              { type = "notification"; }
              { type = "clipboard"; }
            ];
          })
          cfg.settings
        ];
      };
    };
}
