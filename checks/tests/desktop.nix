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
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.general.gaps_in == 5;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.general.gaps_out == 20;
assert
  !hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.general.allow_tearing;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.animations.enabled;
assert
  !hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.animations.workspace_wraparound;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.input.kb_layout
  == "us,de";
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.input.kb_variant
  == ",koy";
assert hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.misc.vrr == 1;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.misc.swallow_regex
  == "'^(foot)$'";
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.decoration.rounding
  == 10;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.config.cursor.no_hardware_cursors;
assert
  hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.device == [
    {
      name = "test-mouse";
      sensitivity = -0.5;
    }
  ];
assert
  builtins.length hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.on == 1;
assert
  builtins.length hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind > 40;
assert
  vmHyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.mod._var == "ALT";
assert
  hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.mod._var == "SUPER";
assert builtins.any (
  binding:
  builtins.isAttrs (builtins.elemAt binding._args 0)
  && pkgs.lib.hasInfix " + return" (builtins.elemAt binding._args 0).expr
  && pkgs.lib.hasInfix "hl.get_workspace(\"special:scratch\")" (builtins.elemAt binding._args 1).expr
  && pkgs.lib.hasInfix "toggle_special(\"scratch\")" (builtins.elemAt binding._args 1).expr
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert builtins.any (
  binding:
  pkgs.lib.hasInfix "hl.get_workspace(\"special:obs\")" (builtins.elemAt binding._args 1).expr
  && pkgs.lib.hasInfix "toggle_special(\"obs\")" (builtins.elemAt binding._args 1).expr
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert builtins.any (
  binding: (builtins.elemAt binding._args 1).expr == ''hl.dsp.workspace.toggle_special("messenger")''
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert builtins.any (
  rule: rule.name == "test-rule"
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.window_rule;
assert builtins.any (
  rule:
  rule.name == "yubico-authenticator"
  && rule.float
  && rule.match.class == "^(yubioath-flutter|com\\.yubico\\.yubioath)$"
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.window_rule;
assert builtins.any (
  rule: rule.name == "tag-jetbrains" && !rule.match.float && rule.tag == "+code"
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.window_rule;
assert builtins.elem "hypr-special" (
  map (package: package.pname or package.name) hyprlandFullHomeEvaluation.config.home.packages
);
assert
  hyprlandPersistenceEvaluation.config.qnix.persist.users."*".files == [
    ".config/hypr/monitors.lua"
    ".config/hypr/workspaces.lua"
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
assert !noctaliaHomeEvaluation.config.programs.noctalia-shell.systemd.enable;
assert
  builtins.length noctaliaHomeEvaluation.config.wayland.windowManager.hyprland.settings.on == 2;
assert builtins.any (
  hook: pkgs.lib.hasInfix "noctalia-shell" (builtins.elemAt hook._args 1).expr
) noctaliaHomeEvaluation.config.wayland.windowManager.hyprland.settings.on;
assert builtins.any (
  binding: pkgs.lib.hasInfix "launcher toggle" (builtins.elemAt binding._args 1).expr
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
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
assert terminalHomeEvaluation.config.programs.foot.package == pkgs.foot;
assert terminalHomeEvaluation.config.programs.foot.server.enable;
assert terminalHomeEvaluation.config.home.sessionVariables.TERMINAL == "footclient";
assert !terminalFallbackHomeEvaluation.config.programs.foot.server.enable;
assert
  terminalFallbackHomeEvaluation.config.home.sessionVariables.TERMINAL == pkgs.lib.getExe pkgs.foot;
assert
  browserFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.brave-origin browserHomeEvaluation.config.home.packages;
assert browserHomeEvaluation.config.qnix.apps.browser.package == pkgs.brave-origin;
assert
  musicFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.tidal-hifi musicHomeEvaluation.config.home.packages;
assert musicHomeEvaluation.config.qnix.apps.music.package == pkgs.tidal-hifi;
assert musicNixosEvaluation.config.qnix.persist.users."*".directories == [ ".config/tidal-hifi" ];
assert builtins.elem pkgs.obsidian notesHomeEvaluation.config.home.packages;
assert notesHomeEvaluation.config.qnix.apps.notes.package == pkgs.obsidian;
assert notesNixosEvaluation.config.qnix.persist.users."*".directories == [ ".config/obsidian" ];
assert builtins.elem pkgs.obs-studio obsHomeEvaluation.config.home.packages;
assert obsHomeEvaluation.config.qnix.apps.obs.package == pkgs.obs-studio;
assert obsNixosEvaluation.config.qnix.persist.users."*".directories == [ ".config/obs-studio" ];
assert builtins.all (package: builtins.elem package socialHomeEvaluation.config.home.packages) [
  pkgs.signal-desktop
  pkgs.element-desktop
];
assert
  socialHomeEvaluation.config.qnix.apps.social.packages == [
    pkgs.signal-desktop
    pkgs.element-desktop
  ];
assert
  socialNixosEvaluation.config.qnix.persist.users."*".directories == [
    ".config/Signal"
    ".config/Element"
  ];
assert
  (builtins.fromJSON (
    builtins.readFile
      browserNixosEvaluation.config.environment.etc."brave/policies/managed/extensions.json".source
  )).ExtensionSettings."nngceckbapebfimnlniiiahkandclblb".installation_mode == "normal_installed";
assert
  (builtins.fromJSON (
    builtins.readFile
      browserNixosEvaluation.config.environment.etc."brave/policies/managed/extensions.json".source
  )).ExtensionSettings."mjcnijlhddpbdemagnpefmlkjdagkogk".installation_mode == "normal_installed";
assert
  (builtins.fromJSON (
    builtins.readFile
      browserNixosEvaluation.config.environment.etc."brave/policies/managed/extensions.json".source
  )).ExtensionSettings."eimadpbcbfnmbkopoojfekhnkhdbieeh".installation_mode == "normal_installed";
assert
  (builtins.fromJSON (
    builtins.readFile
      browserNixosEvaluation.config.environment.etc."brave/policies/managed/extensions.json".source
  )).ExtensionSettings."mdjildafknihdffpkfmmpnpoiajfjnjd".installation_mode == "normal_installed";
assert
  (builtins.fromJSON (
    builtins.readFile
      browserNixosEvaluation.config.environment.etc."brave/policies/managed/extensions.json".source
  )).ExtensionSettings."hfjbmagddngcpeloejdejnfgbamkjaeg".installation_mode == "normal_installed";
assert
  opencodeFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert opencodeHomeEvaluation.config.programs.opencode.enable;
assert opencodeHomeEvaluation.config.xdg.desktopEntries.opencode.name == "OpenCode";
assert opencodeHomeEvaluation.config.xdg.desktopEntries.opencode.terminal;
assert pkgs.lib.hasInfix "opencode-launcher"
  opencodeHomeEvaluation.config.xdg.desktopEntries.opencode.exec;
assert opencodeHomeEvaluation.config.programs.opencode.package == pkgs.llm-agents.opencode;
assert builtins.elem pkgs.llm-agents.rtk
  opencodeHomeEvaluation.config.programs.opencode.extraPackages;
assert builtins.elem pkgs.llm-agents.agent-browser
  opencodeHomeEvaluation.config.programs.opencode.extraPackages;
assert builtins.elem pkgs.llm-agents.officecli
  opencodeHomeEvaluation.config.programs.opencode.extraPackages;
assert builtins.elem pkgs.llm-agents.pdfvision
  opencodeHomeEvaluation.config.programs.opencode.extraPackages;
assert builtins.elem "qnix-signed-commit" (
  map (
    package: package.pname or package.name
  ) opencodeHomeEvaluation.config.programs.opencode.extraPackages
);
assert builtins.elem "qnix-signed-commit" (
  map (package: package.pname or package.name) opencodeHomeEvaluation.config.home.packages
);
assert opencodeHomeEvaluation.config.programs.opencode.enableMcpIntegration;
assert builtins.elem "@satas/opencode-usage-bar@0.2.0"
  opencodeHomeEvaluation.config.programs.opencode.tui.plugin;
assert pkgs.lib.hasInfix "enabled = true"
  opencodeHomeEvaluation.config.xdg.configFile."opencode/usage-bar.toml".text;
assert builtins.hasAttr "opencode/auth.json" opencodeHomeEvaluation.config.xdg.stateFile;
assert builtins.hasAttr "installRtkOpenCodeHook" opencodeHomeEvaluation.config.home.activation;
assert builtins.hasAttr "agent-browser" opencodeHomeEvaluation.config.programs.opencode.skills;
assert builtins.hasAttr "git-signing" opencodeHomeEvaluation.config.programs.opencode.skills;
assert builtins.hasAttr "officecli" opencodeHomeEvaluation.config.programs.opencode.skills;
assert builtins.hasAttr "pdfvision" opencodeHomeEvaluation.config.programs.opencode.skills;
assert builtins.all
  (
    expected:
    builtins.any (
      package: pkgs.lib.hasInfix "-${expected}-" (builtins.baseNameOf (toString package))
    ) aiToolsHomeEvaluation.config.home.packages
  )
  [
    "agent-browser"
    "agentsview"
    "ccusage"
    "codegraph"
    "ctx"
    "officecli"
    "pdfvision"
    "rtk"
    "skills"
  ];
assert builtins.elem "qnix-dev" (
  map (package: package.pname or package.name) aiToolsHomeEvaluation.config.home.packages
);
assert builtins.hasAttr "qnix-ctx" aiToolsHomeEvaluation.config.systemd.user.services;
assert builtins.hasAttr "qnix-agentsview" aiToolsHomeEvaluation.config.systemd.user.services;
assert
  vscodeFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.vscode vscodeHomeEvaluation.config.home.packages;
assert mcpHomeEvaluation.config.programs.mcp.enable;
assert builtins.hasAttr "filesystem" mcpHomeEvaluation.config.programs.mcp.servers;
assert builtins.hasAttr "git" mcpHomeEvaluation.config.programs.mcp.servers;
assert builtins.hasAttr "github" mcpHomeEvaluation.config.programs.mcp.servers;
assert builtins.hasAttr "codegraph" mcpHomeEvaluation.config.programs.mcp.servers;
assert pkgs.lib.hasInfix "qnix-github-mcp-server"
  mcpHomeEvaluation.config.programs.mcp.servers.github.command;
assert mcpHomeEvaluation.config.programs.mcp.servers.github.args == [ ];
assert pkgs.lib.hasInfix "qnix-codegraph-mcp"
  mcpHomeEvaluation.config.programs.mcp.servers.codegraph.command;
assert !(builtins.hasAttr "nixos" mcpHomeEvaluation.config.programs.mcp.servers);
assert
  fileManagerFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.nemo fileManagerHomeEvaluation.config.home.packages;
assert fileManagerHomeEvaluation.config.programs.yazi.enable;
assert fileManagerHomeEvaluation.config.programs.yazi.enableFishIntegration;
assert fileManagerHomeEvaluation.config.programs.yazi.enableZshIntegration;
assert fileManagerHomeEvaluation.config.programs.yazi.plugins.gvfs.setup;
assert builtins.elem pkgs.gvfs fileManagerHomeEvaluation.config.programs.yazi.extraPackages;
assert builtins.elem pkgs.ouch fileManagerHomeEvaluation.config.programs.yazi.extraPackages;
assert builtins.elem pkgs.trash-cli fileManagerHomeEvaluation.config.programs.yazi.extraPackages;
assert builtins.elem "plugin gvfs -- select-then-mount --jump" (
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
assert
  builtins.length hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.on == 1;
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
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert
  screenshotsHomeEvaluation.config.qnix.desktop.screenshots.outputDirectory == "Pictures/Screenshots";
assert builtins.elem "qnix-screenshot-region" (
  map (package: package.pname or package.name) screenshotsHomeEvaluation.config.home.packages
);
assert builtins.elem "qnix-screenshot-full" (
  map (package: package.pname or package.name) screenshotsHomeEvaluation.config.home.packages
);
assert builtins.elem "Print" (
  map (
    binding: builtins.head binding._args
  ) screenshotsHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind
);
assert builtins.all
  (path: builtins.elem path hyprlandProfileEvaluation.config.qnix.persist.users."*".directories)
  [
    ".config/BraveSoftware"
    ".config/opencode/skills"
    ".local/share/opencode"
    ".local/share/yazi"
    ".local/state/yazi"
    "Pictures/Screenshots"
    ".config/easyeffects"
    ".local/state/wireplumber"
  ];
assert builtins.elem ".config/pavucontrol.ini"
  hyprlandProfileEvaluation.config.qnix.persist.users."*".files;
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
  map (
    widget: widget.id
  ) noctaliaHomeEvaluation.config.programs.noctalia-shell.settings.bar.widgets.right == [
    "Tray"
    "plugin:privacy-indicator"
    "plugin:keybind-cheatsheet"
    "NotificationHistory"
    "Volume"
    "plugin:hyprland-steam-overlay"
    "ControlCenter"
  ];
assert noctaliaHomeEvaluation.config.programs.noctalia-shell.settings.settingsVersion == 49;
pkgs.runCommand "qnix-desktop-check" { } "touch $out"
