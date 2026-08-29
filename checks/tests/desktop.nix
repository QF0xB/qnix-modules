{ ctx }:
with ctx;
assert
  waylandFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert waylandNixosEvaluation.config.services.graphical-desktop.enable;
assert waylandNixosEvaluation.config.programs.dconf.enable;
assert waylandNixosEvaluation.config.programs.xwayland.enable;
assert waylandNixosEvaluation.config.xdg.portal.enable;
assert waylandNixosEvaluation.config.xdg.portal.wlr.enable;
assert builtins.elem pkgs.xdg-desktop-portal-gtk
  waylandNixosEvaluation.config.xdg.portal.extraPortals;
assert waylandHomeEvaluation.config.home.sessionVariables.NIXOS_XDG_OPEN_USE_PORTAL == "1";
assert
  hyprlandFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert hyprlandNixosEvaluation.config.programs.hyprland.enable;
assert hyprlandNixosEvaluation.config.programs.hyprland.withUWSM;
assert hyprlandNixosEvaluation.config.programs.uwsm.enable;
assert hyprlandNixosEvaluation.config.environment.sessionVariables.NIXOS_OZONE_WL == "1";
assert hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.enable;
assert !hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.systemd.enable;
assert hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.general.gaps_in == 5;
assert hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.general.gaps_out == 20;
assert !hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.general.allow_tearing;
assert hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.animations.enabled;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.input.kb_layout == "de";
assert hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.misc.vrr == 1;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.misc.swallow_regex
  == "'^(foot)$'";
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.decoration.rounding == 10;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.cursor.no_hardware_cursors;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.device == [
    {
      name = "test-mouse";
      sensitivity = -0.5;
    }
  ];
assert hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind != [ ];
assert builtins.elem "SUPER, F12, exec, true"
  hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.windowrule != [ ];
assert builtins.elem "match:class ^test$, float on"
  hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.windowrule;
assert hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.source != [ ];
assert builtins.elem "hypr-special" (
  map (package: package.pname or package.name) hyprlandFullHomeEvaluation.config.home.packages
);
assert
  hyprlandPersistenceEvaluation.config.qnix.persist.users."*".files == [
    ".config/hypr/monitors.conf"
    ".config/hypr/workspaces.conf"
  ];
assert hyprlandProfileEvaluation.config.qnix.desktop.hyprland.noHardwareCursors;
assert hyprlandStandaloneProfileEvaluation.config.wayland.windowManager.hyprland.enable;
assert
  hyprlandProfileEvaluation.config.qnix.desktop.hyprland.devices."epic-mouse-v1".sensitivity == -0.5;
assert
  noctaliaFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert noctaliaHomeEvaluation.config.programs.noctalia-shell.enable;
assert noctaliaHomeEvaluation.config.programs.noctalia-shell.systemd.enable;
assert
  builtins.baseNameOf
    noctaliaHomeEvaluation.config.home.file."Pictures/wallpaper/solarized-dark.png".source
  == "solarized-dark.png";
assert noctaliaHomeEvaluation.config.programs.noctalia-shell.settings.location.name == "Munich";
assert displayManagerFeature.supportedEnvironments == [ "nixos" ];
assert displayManagerEvaluation.config.services.displayManager.sddm.enable;
assert displayManagerEvaluation.config.services.displayManager.sddm.theme == "sddm-astronaut-theme";
assert displayManagerEvaluation.config.services.xserver.enable;
assert
  lockFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert
  soundFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
  ];
assert soundNixosEvaluation.config.services.pipewire.enable;
assert soundNixosEvaluation.config.services.pipewire.alsa.enable;
assert soundNixosEvaluation.config.services.pipewire.alsa.support32Bit;
assert soundNixosEvaluation.config.services.pipewire.pulse.enable;
assert soundNixosEvaluation.config.security.rtkit.enable;
assert builtins.elem pkgs.playerctl
  soundIntegratedEvaluation.config.home-manager.users.check.home.packages;
assert builtins.elem pkgs.easyeffects
  soundIntegratedEvaluation.config.home-manager.users.check.home.packages;
assert builtins.elem pkgs.pamixer
  soundIntegratedEvaluation.config.home-manager.users.check.home.packages;
assert builtins.elem pkgs.pavucontrol
  soundIntegratedEvaluation.config.home-manager.users.check.home.packages;
assert
  terminalFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert terminalHomeEvaluation.config.programs.foot.enable;
assert terminalHomeEvaluation.config.programs.foot.server.enable;
assert terminalHomeEvaluation.config.home.sessionVariables.TERMINAL == "footclient";
assert !terminalFallbackHomeEvaluation.config.programs.foot.server.enable;
assert
  terminalFallbackHomeEvaluation.config.home.sessionVariables.TERMINAL == pkgs.lib.getExe pkgs.foot;
assert
  browserFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.brave-origin browserHomeEvaluation.config.home.packages;
assert
  chatgptFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert builtins.any (
  package: (package.pname or null) == "chatgpt"
) chatgptHomeEvaluation.config.home.packages;
assert
  vscodeFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.vscode vscodeHomeEvaluation.config.home.packages;
assert mcpHomeEvaluation.config.programs.mcp.enable;
assert builtins.hasAttr "filesystem" mcpHomeEvaluation.config.programs.mcp.servers;
assert builtins.hasAttr "git" mcpHomeEvaluation.config.programs.mcp.servers;
assert builtins.hasAttr "github" mcpHomeEvaluation.config.programs.mcp.servers;
assert !(builtins.hasAttr "nixos" mcpHomeEvaluation.config.programs.mcp.servers);
assert
  aiToolsFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert builtins.all
  (
    package:
    builtins.elem (package.pname or null) (
      map (installed: installed.pname or null) aiToolsHomeEvaluation.config.home.packages
    )
  )
  (
    with pkgs.llm-agents;
    [
      agent-browser
      agentsview
      ccusage
      ck
      codegraph
      ctx
      fence
      git-ai
      gitnexus
      gno
      nono
      officecli
      pdfvision
      qmd
      rtk
      skills
    ]
  );
assert
  fileManagerFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.nemo fileManagerHomeEvaluation.config.home.packages;
assert fileManagerHomeEvaluation.config.programs.yazi.enable;
assert fileManagerHomeEvaluation.config.programs.yazi.enableFishIntegration;
assert fileManagerHomeEvaluation.config.programs.yazi.enableZshIntegration;
assert fileManagerHomeEvaluation.config.programs.yazi.plugins.gvfs.setup;
assert fileManagerHomeEvaluation.config.programs.yazi.plugins.recycle-bin.setup;
assert builtins.elem pkgs.gvfs fileManagerHomeEvaluation.config.programs.yazi.extraPackages;
assert builtins.elem pkgs.ouch fileManagerHomeEvaluation.config.programs.yazi.extraPackages;
assert builtins.elem pkgs.trash-cli fileManagerHomeEvaluation.config.programs.yazi.extraPackages;
assert builtins.elem "plugin gvfs -- select-then-mount --jump" (
  map (binding: binding.run) fileManagerHomeEvaluation.config.programs.yazi.keymap.mgr.prepend_keymap
);
assert builtins.elem "plugin recycle-bin" (
  map (binding: binding.run) fileManagerHomeEvaluation.config.programs.yazi.keymap.mgr.prepend_keymap
);
assert
  fileManagerHomeEvaluation.config.gtk.gtk3.bookmarks == [
    "file:///home/check Home"
    "file:///home/check/Projects Projects"
    "file:///home/check/Documents Documents"
    "file:///home/check/Downloads Downloads"
    "file:///home/check/Music Music"
    "file:///home/check/Pictures Pictures"
    "file:///home/check/Videos Videos"
  ];
assert builtins.elem "super SHIFT, return, exec, uwsm app -- footclient"
  hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert builtins.elem "super, code:40, exec, uwsm app -- footclient -e yazi #d"
  hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert
  noctaliaHomeEvaluation.config.programs.noctalia-shell.settings.appLauncher.terminalCommand
  == "footclient -e";
assert
  xdgFoldersFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert xdgFoldersHomeEvaluation.config.xdg.userDirs.enable;
assert xdgFoldersHomeEvaluation.config.xdg.userDirs.createDirectories;
assert xdgFoldersHomeEvaluation.config.xdg.userDirs.setSessionVariables;
assert xdgFoldersHomeEvaluation.config.xdg.userDirs.projects == "/home/check/Projects";
assert
  clipboardFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert clipboardHomeEvaluation.config.services.cliphist.enable;
assert clipboardHomeEvaluation.config.services.cliphist.allowImages;
assert
  screenshotsFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert
  screenshotsHomeEvaluation.config.qnix.desktop.screenshots.outputDirectory
  == "/home/check/Pictures/Screenshots";
assert builtins.elem "qnix-screenshot-region" (
  map (package: package.pname or package.name) screenshotsHomeEvaluation.config.home.packages
);
assert builtins.elem "qnix-screenshot-full" (
  map (package: package.pname or package.name) screenshotsHomeEvaluation.config.home.packages
);
assert builtins.any (
  binding: builtins.match ".*qnix-screenshot-region.*" binding != null
) screenshotsHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert builtins.any (
  binding: builtins.match ".*qnix-screenshot-full.*" binding != null
) screenshotsHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert lockNixosEvaluation.config.security.pam.services.hyprlock.enable;
assert lockHomeEvaluation.config.programs.hyprlock.enable;
assert
  builtins.baseNameOf (
    toString (builtins.elemAt lockHomeEvaluation.config.programs.hyprlock.settings.background 0).path
  ) == "solarized-dark.png";
assert
  (builtins.elemAt lockHomeEvaluation.config.programs.hyprlock.settings.background 0).blur_passes
  == 3;
assert
  (builtins.elemAt lockHomeEvaluation.config.programs.hyprlock.settings.input-field 0).rounding == 10;
assert
  noctaliaHomeEvaluation.config.programs.noctalia-shell.settings.bar.widgets.right == [
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
pkgs.runCommand "qnix-desktop-check" { } "touch $out"
