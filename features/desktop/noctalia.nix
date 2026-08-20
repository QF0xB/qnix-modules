{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.hyprland" ];

  options =
    { lib, ... }:
    {
      autostart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Noctalia should start with the graphical session.";
      };

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {
          appLauncher = {
            iconMode = "tabler";
            position = "center";
            terminalCommand = "alacritty -e";
            viewMode = "grid";
          };

          audio = {
            volumeFeedback = false;
            volumeOverdrive = false;
            volumeStep = 5;
          };

          bar = {
            barType = "floating";
            density = "comfortable";
            displayMode = "always_visible";
            floating = true;
            marginHorizontal = 8;
            marginVertical = 16;
            position = "left";
            widgets = {
              center = [
                {
                  id = "Workspace";
                  labelMode = "index";
                  showApplications = false;
                }
              ];
              left = [
                {
                  icon = "rocket";
                  id = "Launcher";
                }
                {
                  id = "Clock";
                  formatHorizontal = "HH:mm";
                  formatVertical = "HH mm";
                }
                {
                  id = "KeyboardLayout";
                  displayMode = "forceOpen";
                }
                {
                  id = "Network";
                  displayMode = "onhover";
                }
              ];
              right = [
                { id = "Tray"; }
                { id = "plugin:privacy-indicator"; }
                { id = "plugin:keybind-cheatsheet"; }
                { id = "NotificationHistory"; }
                {
                  id = "Volume";
                  displayMode = "alwaysHide";
                  middleClickCommand = "pwvucontrol || pavucontrol";
                }
                { id = "plugin:hyprland-steam-overlay"; }
                {
                  id = "Battery";
                  displayMode = "graphic-clean";
                  hideIfNotDetected = true;
                  showPowerProfiles = true;
                }
                {
                  id = "Brightness";
                  displayMode = "alwaysHide";
                }
                {
                  id = "ControlCenter";
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
            clockFormat = "hh\\nmmddd, MMM dd ";
            clockStyle = "custom";
            dimmerOpacity = 0.2;
            enableLockScreenCountdown = true;
            enableShadows = true;
            lockOnSuspend = true;
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
            panelBackgroundOpacity = 1;
            panelsAttachedToBar = true;
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
    {
      programs.noctalia-shell = {
        enable = true;
        systemd.enable = cfg.autostart;
        settings = lib.recursiveUpdate cfg.settings {
          wallpaper.directory =
            cfg.settings.wallpaper.directory or "${config.home.homeDirectory}/Pictures/wallpaper";
        };
      };
    };
}
