{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.desktop.noctalia or { enable = false; };
  isLaptop = qconfig.status.laptop or false;
  screenshotsCfg = qconfig.desktop.screenshots or { annotationTool = ""; };
in
{
  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = lib.mkForce {
        settingsVersion = 49;

        bar = {
          barType = "floating";
          position = "left";
          monitors = [ ];
          density = "comfortable";
          showOutline = false;
          showCapsule = true;
          capsuleColorKey = "none";
          useSeparateOpacity = false;
          floating = true;
          marginVertical = 16;
          marginHorizontal = 8;
          frameThickness = 2;
          frameRadius = 10;
          outerCorners = true;
          hideOnOverview = false;
          displayMode = "always_visible";
          autoHideDelay = 500;
          autoShowDelay = 150;
          widgets = {
            left = [
              {
                icon = "rocket";
                iconColor = "primary";
                id = "Launcher";
              }
              {
                clockColor = "none";
                customFont = "Fira Sans Book";
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                tooltipFormat = "HH:mm ddd, MMM dd";
                useCustomFont = false;
              }
              {
                displayMode = "forceOpen";
                iconColor = "none";
                id = "KeyboardLayout";
                showIcon = true;
                textColor = "none";
              }
              {
                displayMode = "onhover";
                iconColor = "none";
                id = "Network";
                textColor = "none";
              }
            ];
            center = [
              {
                characterCount = 2;
                colorizeIcons = false;
                emptyColor = "secondary";
                enableScrollWheel = true;
                focusedColor = "primary";
                followFocusedScreen = false;
                groupedBorderOpacity = 1;
                hideUnoccupied = true;
                iconScale = 0.8;
                id = "Workspace";
                labelMode = "index";
                occupiedColor = "secondary";
                pillSize = 0.6;
                reverseScroll = true;
                showApplications = false;
                showBadge = true;
                showLabelsOnlyWhenOccupied = true;
                unfocusedIconsOpacity = 1;
              }
            ];
            right = [
              {
                blacklist = [ ];
                chevronColor = "none";
                colorizeIcons = true;
                drawerEnabled = true;
                hidePassive = false;
                id = "Tray";
                pinned = [ ];
              }
              {
                id = "plugin:privacy-indicator";
              }
              {
                id = "plugin:keybind-cheatsheet";
              }
              {
                hideWhenZero = false;
                hideWhenZeroUnread = false;
                iconColor = "none";
                id = "NotificationHistory";
                showUnreadBadge = true;
                unreadBadgeColor = "primary";
              }
              {
                displayMode = "alwaysHide";
                iconColor = "none";
                id = "Volume";
                middleClickCommand = "pwvucontrol || pavucontrol";
                textColor = "none";
              }
              {
                id = "plugin:hyprland-steam-overlay";
              }
              {
                colorizeDistroLogo = false;
                colorizeSystemIcon = "primary";
                customIconPath = "";
                enableColorization = true;
                icon = "noctalia";
                id = "ControlCenter";
                useDistroLogo = true;
              }
            ]
            ++ lib.optionals isLaptop [
              {
                deviceNativePath = "__default__";
                displayMode = "graphic-clean";
                hideIfIdle = false;
                hideIfNotDetected = true;
                id = "Battery";
                showNoctaliaPerformance = true;
                showPowerProfiles = true;
              }
              {
                displayMode = "alwaysHide";
                iconColor = "none";
                id = "Brightness";
                textColor = "none";
              }
            ];
          };
          screenOverrides = [ ];
        };

        general = {
          avatarImage = "${config.home.homeDirectory}/.face";
          dimmerOpacity = 0.2;
          showScreenCorners = false;
          forceBlackScreenCorners = false;
          scaleRatio = 1;
          radiusRatio = 0.2;
          iRadiusRatio = 1;
          boxRadiusRatio = 1;
          screenRadiusRatio = 1;
          animationSpeed = 1;
          animationDisabled = false;
          compactLockScreen = false;
          lockScreenAnimations = true;
          lockOnSuspend = true;
          showSessionButtonsOnLockScreen = true;
          showHibernateOnLockScreen = true;
          enableShadows = true;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          language = "";
          allowPanelsOnScreenWithoutBar = true;
          showChangelogOnStartup = true;
          telemetryEnabled = false;
          enableLockScreenCountdown = true;
          lockScreenCountdownDuration = 10000;
          autoStartAuth = false;
          allowPasswordWithFprintd = false;
          clockStyle = "custom";
          clockFormat = "hh\\nmmddd, MMM dd ";
          lockScreenMonitors = [ ];
          keybinds = {
            keyUp = "Up";
            keyDown = "Down";
            keyLeft = "Left";
            keyRight = "Right";
            keyEnter = "Return";
            keyEscape = "Esc";
          };
        };

        ui = {
          fontDefault = "Fira Sans";
          fontFixed = "JetBrains Mono Nerd Font";
          fontDefaultScale = 1;
          fontFixedScale = 1;
          tooltipsEnabled = true;
          panelBackgroundOpacity = 1;
          panelsAttachedToBar = true;
          settingsPanelMode = "attached";
          wifiDetailsViewMode = "grid";
          bluetoothDetailsViewMode = "grid";
          networkPanelView = "wifi";
          bluetoothHideUnnamedDevices = false;
          boxBorderEnabled = false;
        };

        location = {
          name = "Munich";
          weatherEnabled = true;
          weatherShowEffects = true;
          useFahrenheit = false;
          use12hourFormat = false;
          showWeekNumberInCalendar = false;
          showCalendarEvents = true;
          showCalendarWeather = true;
          analogClockInCalendar = false;
          firstDayOfWeek = -1;
          hideWeatherTimezone = false;
          hideWeatherCityName = false;
        };

        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
          ];
        };

        wallpaper = {
          enabled = true;
          overviewEnabled = false;
          directory = config.home.homeDirectory + "/Pictures/wallpaper";
          monitorDirectories = [ ];
          enableMultiMonitorDirectories = false;
          showHiddenFiles = false;
          viewMode = "single";
          setWallpaperOnAllMonitors = true;
          fillMode = "crop";
          fillColor = "#000000";
          useSolidColor = false;
          solidColor = "#1a1a2e";
          automationEnabled = false;
          wallpaperChangeMode = "random";
          randomIntervalSec = 300;
          transitionDuration = 2500;
          transitionType = "honeycomb";
          transitionEdgeSmoothness = 0.10;
          panelPosition = "follow_bar";
          hideWallpaperFilenames = false;
          useWallhaven = false;
          wallhavenQuery = "";
          wallhavenSorting = "relevance";
          wallhavenOrder = "desc";
          wallhavenCategories = "111";
          wallhavenPurity = "100";
          wallhavenRatios = "";
          wallhavenApiKey = "";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenResolutionHeight = "";
          sortOrder = "name";
        };

        appLauncher = {
          enableClipboardHistory = true;
          autoPasteClipboard = false;
          enableClipPreview = true;
          clipboardWrapText = true;
          clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
          clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
          position = "center";
          pinnedApps = [ ];
          useApp2Unit = false;
          sortByMostUsed = true;
          terminalCommand = "alacritty -e";
          customLaunchPrefixEnabled = false;
          customLaunchPrefix = "";
          viewMode = "grid";
          showCategories = true;
          iconMode = "tabler";
          showIconBackground = false;
          enableSettingsSearch = true;
          enableWindowsSearch = true;
          ignoreMouseInput = false;
          screenshotAnnotationTool = screenshotsCfg.annotationTool;
          overviewLayer = true;
        };

        controlCenter = {
          position = "bottom_left";
          diskPath = "/";
          shortcuts = {
            left = [
              { id = "Network"; }
              { id = "Bluetooth"; }
              { id = "WallpaperSelector"; }
            ]
            ++ lib.optionals isLaptop [
              { id = "NoctaliaPerformance"; }
            ];
            right = [
              { id = "Notifications"; }
              { id = "PowerProfile"; }
              { id = "KeepAwake"; }
              { id = "NightLight"; }
            ];
          };
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ]
          ++ lib.optionals isLaptop [
            {
              enabled = true;
              id = "brightness-card";
            }
          ];
        };

        systemMonitor = {
          cpuWarningThreshold = 80;
          cpuCriticalThreshold = 90;
          tempWarningThreshold = 80;
          tempCriticalThreshold = 90;
          gpuWarningThreshold = 80;
          gpuCriticalThreshold = 90;
          memWarningThreshold = 80;
          memCriticalThreshold = 90;
          swapWarningThreshold = 80;
          swapCriticalThreshold = 90;
          diskWarningThreshold = 80;
          diskCriticalThreshold = 90;
          diskAvailWarningThreshold = 20;
          diskAvailCriticalThreshold = 10;
          batteryWarningThreshold = 20;
          batteryCriticalThreshold = 5;
          cpuPollingInterval = 1000;
          gpuPollingInterval = 3000;
          enableDgpuMonitoring = false;
          memPollingInterval = 1000;
          diskPollingInterval = 30000;
          networkPollingInterval = 1000;
          loadAvgPollingInterval = 3000;
          useCustomColors = false;
          warningColor = "";
          criticalColor = "";
          externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        };

        dock = {
          enabled = false;
          position = "bottom";
          displayMode = "always_visible";
          backgroundOpacity = 1;
          floatingRatio = 1;
          size = 1;
          onlySameOutput = true;
          monitors = [ ];
          pinnedApps = [ ];
          colorizeIcons = false;
          pinnedStatic = true;
          inactiveIndicators = true;
          deadOpacity = 0.6;
          animationSpeed = 1;
        };

        network = {
          wifiEnabled = true;
          bluetoothRssiPollingEnabled = false;
          bluetoothRssiPollIntervalMs = 10000;
          wifiDetailsViewMode = "grid";
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = false;
        };

        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 10000;
          position = "center";
          showHeader = true;
          largeButtonsStyle = true;
          largeButtonsLayout = "single-row";
          showNumberLabels = true;
          powerOptions = [
            {
              action = "lock";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "";
            }
            {
              action = "suspend";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "";
            }
            {
              action = "hibernate";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "";
            }
            {
              action = "reboot";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "";
            }
            {
              action = "logout";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "";
            }
            {
              action = "shutdown";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "";
            }
          ];
        };

        notifications = {
          enabled = true;
          monitors = [ ];
          location = "top_right";
          overlayLayer = true;
          backgroundOpacity = 1;
          respectExpireTimeout = false;
          lowUrgencyDuration = 3;
          normalUrgencyDuration = 8;
          criticalUrgencyDuration = 15;
          saveToHistory = {
            low = true;
            normal = true;
            critical = true;
          };
          sounds = {
            enabled = false;
            volume = 0.5;
            separateSounds = false;
            criticalSoundFile = "";
            normalSoundFile = "";
            lowSoundFile = "";
            excludedApps = "discord,firefox,chrome,chromium,edge";
          };
          enableMediaToast = true;
          enableKeyboardLayoutToast = true;
          enableBatteryToast = isLaptop;
        };

        osd = {
          enabled = true;
          location = "top_right";
          autoHideMs = 2000;
          overlayLayer = true;
          backgroundOpacity = 1;
          enabledTypes = [
            0
            1
            2
            3
          ];
          monitors = [ ];
        };

        audio = {
          volumeStep = 5;
          volumeOverdrive = false;
          cavaFrameRate = 30;
          visualizerType = "linear";
          mprisBlacklist = [ ];
          preferredPlayer = "";
          volumeFeedback = false;
        };

        brightness = {
          brightnessStep = 5;
          enforceMinimum = true;
          enableDdcSupport = false;
        };
      };
    };
  };
}
