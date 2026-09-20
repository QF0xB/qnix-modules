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
    { context, lib, ... }:
    {
      autostart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Noctalia should start with the graphical session.";
      };

      notificationSounds = lib.mkOption {
        type = lib.types.bool;
        default = !(context.laptop or false);
        description = "Whether Noctalia notification sounds are enabled.";
      };

      location = lib.mkOption {
        type = lib.types.str;
        default = "Munich";
        description = "City used by Noctalia for weather and location-aware features.";
      };

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {
          settingsVersion = 49;

          appLauncher = {
            enableClipboardHistory = true;
            autoPasteClipboard = false;
            enableClipPreview = true;
            clipboardWrapText = true;
            clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
            clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
            iconMode = "tabler";
            position = "center";
            terminalCommand = "foot -e";
            viewMode = "grid";
          };

          audio = {
            volumeFeedback = false;
            volumeOverdrive = false;
            volumeStep = 5;
          };

          bar = {
            barType = "floating";
            capsuleColorKey = "none";
            density = "comfortable";
            displayMode = "always_visible";
            frameRadius = 10;
            frameThickness = 2;
            floating = true;
            hideOnOverview = false;
            marginHorizontal = 8;
            marginVertical = 16;
            outerCorners = true;
            position = "left";
            showCapsule = true;
            showOutline = false;
            widgets = {
              center = [
                {
                  characterCount = 2;
                  colorizeIcons = false;
                  emptyColor = "secondary";
                  enableScrollWheel = true;
                  focusedColor = "primary";
                  hideUnoccupied = true;
                  id = "Workspace";
                  iconScale = 0.8;
                  labelMode = "index";
                  occupiedColor = "secondary";
                  pillSize = 0.6;
                  reverseScroll = true;
                  showApplications = false;
                  showBadge = true;
                  showLabelsOnlyWhenOccupied = true;
                }
              ];
              left = [
                {
                  icon = "rocket";
                  id = "Launcher";
                }
                {
                  id = "Clock";
                  clockColor = "none";
                  formatHorizontal = "HH:mm";
                  formatVertical = "HH mm";
                  tooltipFormat = "HH:mm ddd, MMM dd";
                }
                {
                  id = "KeyboardLayout";
                  displayMode = "forceOpen";
                  showIcon = true;
                }
                {
                  id = "Network";
                  displayMode = "onhover";
                }
              ];
              right = [
                { id = "Tray"; }
                { id = "NotificationHistory"; }
                {
                  id = "Volume";
                  displayMode = "alwaysHide";
                  middleClickCommand = "pwvucontrol || pavucontrol";
                }
              ]
              ++ lib.optionals (context.laptop or false) [
                {
                  id = "Battery";
                  deviceNativePath = "__default__";
                  displayMode = "graphic-clean";
                  hideIfIdle = false;
                  hideIfNotDetected = true;
                  showNoctaliaPerformance = true;
                  showPowerProfiles = true;
                }
                {
                  id = "Brightness";
                  displayMode = "alwaysHide";
                }
              ]
              ++ [
                {
                  id = "ControlCenter";
                  colorizeDistroLogo = false;
                  colorizeSystemIcon = "primary";
                  icon = "noctalia";
                  useDistroLogo = true;
                }
              ];
            };
          };

          controlCenter = {
            diskPath = "/";
            position = "bottom_left";
          };

          general = {
            animationDisabled = false;
            animationSpeed = 1;
            autoStartAuth = false;
            clockFormat = "hh\\nmmddd, MMM dd ";
            clockStyle = "custom";
            compactLockScreen = false;
            dimmerOpacity = 0.2;
            enableLockScreenCountdown = true;
            enableShadows = true;
            lockScreenAnimations = true;
            lockOnSuspend = true;
            showSessionButtonsOnLockScreen = true;
            telemetryEnabled = false;
          };

          location = {
            name = "Munich";
            showCalendarEvents = true;
            showCalendarWeather = true;
            use12hourFormat = false;
            weatherEnabled = true;
          };

          notifications = {
            enabled = true;
            location = "top_right";
            sounds.enabled = false;
          };

          osd = {
            enabled = true;
            location = "top_right";
          };

          ui = {
            fontDefault = "Fira Sans";
            fontFixed = "JetBrains Mono Nerd Font";
            fontDefaultScale = 1;
            fontFixedScale = 1;
            panelBackgroundOpacity = 1.0;
            panelsAttachedToBar = true;
            settingsPanelMode = "attached";
            tooltipsEnabled = true;
          };

          wallpaper = {
            automationEnabled = false;
            enabled = true;
            fillMode = "crop";
            setWallpaperOnAllMonitors = true;
            transitionDuration = 2500;
            transitionType = "honeycomb";
          };
        };
        description = "Default Noctalia shell settings.";
      };
    };

  home =
    {
      cfg,
      config,
      lib,
      ...
    }:
    let
      terminal = if config.programs.foot.server.enable then "footclient" else "foot";
    in
    {
      home.file."Pictures/wallpaper/solarized-dark.png".source =
        ../../assets/wallpapers/solarized-dark.png;

      programs.noctalia-shell = {
        enable = true;
        settings = lib.recursiveUpdate cfg.settings {
          appLauncher.terminalCommand = "${terminal} -e";
          location.name = cfg.location;
          notifications.sounds.enabled = cfg.notificationSounds;
          wallpaper.directory =
            cfg.settings.wallpaper.directory or "${config.home.homeDirectory}/Pictures/wallpaper";
        };
      };

      wayland.windowManager.hyprland.settings.on = lib.mkIf cfg.autostart [
        {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''
              function()
                hl.exec_cmd("noctalia-shell")
              end
            '')
          ];
        }
      ];
    };
}
