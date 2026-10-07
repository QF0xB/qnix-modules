{
  environments = [
    "integrated-home"
    "standalone-home"
    "nixos"
  ];

  requires = {
    home = [
      "desktop.hyprland"
      "desktop.terminal"
    ];
    nixos = ["security.polkit"];
  };

  persistence.users."*".directories = [".local/state/qnix/noctalia-wallpapers"];

  options = {
    lib,
    pkgs,
    ...
  }: {
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to start Noctalia through systemd with the graphical session.";
    };

    calendar = {
      subscriptions = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "Display name of the iCalendar subscription.";
            };
            url = lib.mkOption {
              type = lib.types.str;
              description = "URL of the iCalendar (.ics) feed.";
            };
          };
        }));
        default = {};
        description = "Read-only iCalendar subscriptions, keyed by account identifier.";
      };

      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Noctalia's calendar integration.";
      };

      icloud = {
        enable = lib.mkEnableOption "the iCloud calendar account";

        email = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Apple ID email address used to authenticate with iCloud CalDAV.";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "iCloud";
          description = "Display name of the iCloud calendar account.";
        };

        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Absolute runtime path to the app-specific password file. When null, Noctalia uses Secret Service.";
        };

        calendars = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Calendar identifiers to include; an empty list includes all calendars.";
        };
      };
    };

    settings = lib.mkOption {
      type = (pkgs.formats.toml {}).type;
      default = {};
      description = "Overrides for Noctalia's upstream defaults, serialized as TOML by Home Manager.";
      example = {
        bar.main.position = "left";
        location.address = "Munich";
      };
    };
  };

  nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.efibootmgr
      pkgs.linux-wifi-hotspot
    ];
  };

  home = {
    cfg,
    context,
    lib,
    pkgs,
    ...
  }: let
    wallpaperStateScript = pkgs.writeShellScript "qnix-noctalia-wallpaper-state" ''
      set -euo pipefail

      state_dir="$HOME/.local/state/qnix/noctalia-wallpapers"

      case "''${1:-}" in
        save)
          path="''${NOCTALIA_WALLPAPER_PATH:-}"
          connector="''${NOCTALIA_WALLPAPER_CONNECTOR:-}"
          [[ -n "$path" ]] || exit 0

          if [[ -n "$connector" ]]; then
            [[ "$connector" =~ ^[[:alnum:]_.-]+$ ]] || exit 0
            state_file="$state_dir/monitor-$connector"
          else
            state_file="$state_dir/default"
          fi

          umask 077
          mkdir -p "$state_dir"
          printf '%s\n' "$path" > "$state_file.tmp.$$"
          mv "$state_file.tmp.$$" "$state_file"
          ;;

        restore)
          mkdir -p "$state_dir"

          if [[ -r "$state_dir/default" ]]; then
            path="$(< "$state_dir/default")"
            [[ -n "$path" ]] && noctalia msg wallpaper-set "$path" || true
          fi

          for state_file in "$state_dir"/monitor-*; do
            [[ -f "$state_file" ]] || continue
            connector="''${state_file##*/monitor-}"
            path="$(< "$state_file")"
            [[ "$connector" =~ ^[[:alnum:]_.-]+$ && -n "$path" ]] || continue
            noctalia msg wallpaper-set "$connector" "$path" || true
          done
          ;;

        *)
          exit 64
          ;;
      esac
    '';
  in {
    assertions = [
      {
        assertion = !cfg.calendar.icloud.enable || cfg.calendar.icloud.email != "";
        message = "qnix.desktop.noctalia.calendar.icloud.email must be set when the iCloud account is enabled.";
      }
      {
        assertion =
          cfg.calendar.icloud.passwordFile
          == null
          || lib.hasPrefix "/" cfg.calendar.icloud.passwordFile;
        message = "qnix.desktop.noctalia.calendar.icloud.passwordFile must be an absolute runtime path.";
      }
    ];

    home.packages = with pkgs; [
      jq
      libnotify
      networkmanager
      iproute2
      iw
      nix-search-tv
      fzf
      xdg-utils
      git
      coreutils
      gawk
      gnugrep
      procps
      openssh
      libvirt
      virt-viewer
      findutils
      util-linux
      glib.bin
      bash
      docker-client
    ];

    home.file."Pictures/wallpaper".source =
      ../../assets/wallpapers;

    programs.noctalia = {
      enable = true;
      systemd.enable = cfg.autostart;
      settings = lib.mkMerge [
        {
          calendar = {
            enabled = lib.mkDefault cfg.calendar.enable;
            account =
              lib.mapAttrs (_: subscription: {
                type = "ics";
                name = subscription.name;
                server_url = subscription.url;
              })
              cfg.calendar.subscriptions
              // lib.optionalAttrs cfg.calendar.icloud.enable {
                personal_icloud = lib.mkDefault (
                  {
                    type = "caldav";
                    provider = "icloud";
                    name = cfg.calendar.icloud.name;
                    username = cfg.calendar.icloud.email;
                    calendars = cfg.calendar.icloud.calendars;
                    credential_source =
                      if cfg.calendar.icloud.passwordFile == null
                      then "secret-service"
                      else "file";
                  }
                  // lib.optionalAttrs (cfg.calendar.icloud.passwordFile != null) {
                    password_file = cfg.calendar.icloud.passwordFile;
                  }
                );
              };
          };
          location = {
            auto_locate = true;
          };

          wallpaper = {
            directory = "/home/q.braendli/Pictures/wallpaper";
            transition = ["honeycomb"];
          };

          wallpaper.default = {
            path = "/home/q.braendli/Pictures/wallpaper/solarized-dark.png";
          };

          bar.default = {
            center = ["workspaces"];
            end = [
              "tray"
              "group:g2"
              "notifications"
              "clipboard"
              "group:g1"
              "volume"
              "brightness"
              "battery"
              "control-center"
            ];
            start = ["launcher" "clock" "group:g3" "privacy" "lock_keys"];
            capsule_group = [
              {
                accordion = true;
                accordion_direction = "start";
                border_width = 1.0;
                enabled = true;
                fill = "#073642";
                id = "g1";
                members = ["network" "bluetooth"];
                opacity = 1.0;
                padding = 6.0;
              }
              {
                accordion = true;
                accordion_direction = "start";
                border_width = 1.0;
                enabled = true;
                fill = "#073642";
                id = "g2";
                members = ["nix-monitor" "status_2" "nextboot-selector"];
                opacity = 1.0;
                padding = 6.0;
              }
              {
                accordion = true;
                accordion_direction = "end";
                border_width = 1.0;
                enabled = true;
                fill = "#073642";
                id = "g3";
                members = ["bar" "status"];
                opacity = 1.0;
                padding = 6.0;
              }
            ];
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
            transition = lib.mkDefault ["honeycomb"];
          };

          lockscreen_widgets = {
            enabled = false;
            schema_version = 2;
            widget_order = [
              "lockscreen-login-box@DP-5"
              "lockscreen-login-box@DP-3"
              "lockscreen-login-box@HDMI-A-2"
            ];
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = true;
            };
            widget = lib.mapAttrs (_: geometry:
              geometry
              // {
                box_height = 196.0;
                box_width = 810.0;
                rotation = 0.0;
                type = "login_box";
                settings = {
                  background_color = "surface_variant";
                  background_opacity = 0.88;
                  background_radius = 12.0;
                  center_password_text = false;
                  input_opacity = 1.0;
                  input_radius = 6.0;
                  layout = "regular";
                  show_caps_lock = true;
                  show_keyboard_layout = true;
                  show_login_button = true;
                  show_media = true;
                  show_session_buttons = true;
                  show_unlock_hint = true;
                  show_weather = true;
                };
              }) {
              "lockscreen-login-box@DP-3" = {
                cx = 1280.0;
                cy = 1258.0;
                output = "DP-3";
                placement_height = 1440.0;
                placement_width = 2560.0;
              };
              "lockscreen-login-box@DP-5" = {
                cx = 960.0;
                cy = 1018.0;
                output = "DP-5";
                placement_height = 1200.0;
                placement_width = 1920.0;
              };
              "lockscreen-login-box@HDMI-A-2" = {
                cx = 640.0;
                cy = 538.0;
                output = "HDMI-A-2";
                placement_height = 720.0;
                placement_width = 1280.0;
              };
            };
          };

          widget = {
            bar.type = "ahmedhossamdev/reading-list:bar";
            launcher.glyph = "rocket";
            lock_keys = {
              hide_when_off = true;
              show_num_lock = false;
            };
            network.show_label = true;
            nextboot-selector.type = "avivbintangaringga/nextboot-selector:nextboot-selector";
            nix-monitor = {
              show_text = false;
              type = "avivbintangaringga/nix-monitor:nix-monitor";
            };
            privacy.hide_inactive = true;
            status = {
              type = "davemhammer/obsidian:status";
              show_dirty = false;
            };
            status_2.type = "tiobaka/vm-manager:status";
            tray = {
              drawer = true;
              hidden = ["nm-applet" "blueman"];
            };
            volume.show_label = false;
          };

          shell = {
            external_ip_enabled = lib.mkDefault true;
            settings_window_translucent = lib.mkDefault true;
            polkit_agent = lib.mkDefault true;
            launch_apps_as_systemd_services = lib.mkDefault true;
            session.actions = [
              {
                action = "lock";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "1";
                variant = "default";
              }
              {
                action = "logout";
                command = "uwsm stop";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "2";
                variant = "default";
              }
              {
                action = "lock_and_suspend";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "3";
                variant = "default";
              }
              {
                action = "reboot";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "4";
                variant = "default";
              }
              {
                action = "shutdown";
                countdown_seconds = 0.0;
                enabled = true;
                shortcut = "5";
                variant = "destructive";
              }
            ];
          };

          shell.greeter_sync = {
            auto_sync = true;
          };

          hooks = {
            started = "${wallpaperStateScript} restore";
            wallpaper_changed = "${wallpaperStateScript} save";
          };

          shell.panel = {
            open_near_click_control_center = lib.mkDefault true;
            open_near_click_session = lib.mkDefault true;
          };

          notification = {
            follow_focused_output = lib.mkDefault true;
          };

          plugins.enabled = [
            "conqazht/share-wifi"
            "umedbazarov/crashes"
            "avivbintangaringga/nextboot-selector"
            "avivbintangaringga/nix-monitor"
            "knyrps/nix-search"
            "cleboost/ssh-launcher"
            "srounce/systemd"
            "tiobaka/vm-manager"
            "nightwatch75/file-search"
            "cleboost/jetbrains-provider"
            "8bury/mini-docker"
            "davemhammer/obsidian"
            "ahmedhossamdev/reading-list"
          ];
          plugin_settings."umedbazarov/crashes" = {
            agent_cmd = "paseo run --provider codex/gpt-6-luna";
            terminal_cmd = "footclient -e";
          };

          plugin_settings."ahmedhossamdev/reading-list" = {
            save_path = "~/Documents/personal/50 - Sources/ReadingList";
          };
          plugin_settings."davemhammer/obsidian" = {
            daily_folder = "30 - Journal/Daily/";
            manager_placement = "attached";
            vault_path = "/home/q.braendli/Documents/personal/";
          };
          plugin_settings."avivbintangaringga/nextboot-selector".privilege_command = "pkexec";
        }
        (lib.mkIf (!(context.laptop or false)) {
          control_center.shortcuts = lib.mkDefault [
            {type = "wifi";}
            {type = "bluetooth";}
            {type = "caffeine";}
            {type = "nightlight";}
            {type = "notification";}
            {type = "clipboard";}
          ];
        })
        cfg.settings
      ];
    };
  };
}
