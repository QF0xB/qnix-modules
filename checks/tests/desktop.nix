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
  == "'^(foot|footclient)$'";
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
  builtins.isAttrs (builtins.elemAt binding._args 0)
  && pkgs.lib.hasInfix "SHIFT + code:24" (builtins.elemAt binding._args 0).expr
  && pkgs.lib.hasInfix "opencode-scratch" (builtins.elemAt binding._args 1).expr
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert builtins.any (
  rule:
  rule.name == "opencode-scratch-workspace"
  && rule.match.class == "^(opencode-scratch)$"
  && rule.workspace == "special:scratch"
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.window_rule;
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
  rule: rule.name == "yazi-workspace" && rule.match.class == "^(yazi)$" && rule.workspace == "9"
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.window_rule;
assert builtins.any (
  rule:
  rule.name == "yubico-authenticator"
  && rule.float
  && pkgs.lib.hasInfix "yubioath-flutter" rule.match.class
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
assert hyprlandProfileEvaluation.config.security.polkit.enable;
assert builtins.elem pkgs.efibootmgr hyprlandProfileEvaluation.config.environment.systemPackages;
assert builtins.elem pkgs.linux-wifi-hotspot hyprlandProfileEvaluation.config.environment.systemPackages;
assert hyprlandStandaloneProfileEvaluation.config.wayland.windowManager.hyprland.enable;
assert builtins.all
  (package: builtins.elem package hyprlandStandaloneProfileEvaluation.config.home.packages)
  [
    pkgs.hyprland
    pkgs.uwsm
  ];
assert
  hyprlandProfileEvaluation.config.qnix.desktop.hyprland.devices."epic-mouse-v1".sensitivity == -0.5;
assert
  noctaliaFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
    "nixos"
  ];
assert noctaliaHomeEvaluation.config.programs.noctalia.enable;
assert noctaliaHomeEvaluation.config.programs.noctalia.systemd.enable;
assert builtins.all (package: builtins.elem package noctaliaHomeEvaluation.config.home.packages) [
  pkgs.jq
  pkgs.libnotify
  pkgs.networkmanager
  pkgs.iproute2
  pkgs.iw
  pkgs.nix-search-tv
  pkgs.fzf
  pkgs.xdg-utils
  pkgs.git
  pkgs.coreutils
  pkgs.gawk
  pkgs.gnugrep
  pkgs.procps
  pkgs.openssh
  pkgs.libvirt
  pkgs.virt-viewer
  pkgs.findutils
  pkgs.util-linux
  pkgs.glib.bin
  pkgs.bash
  pkgs.docker-client
];
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.plugins.enabled == [
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
];
assert
  noctaliaHomeEvaluation.config.programs.noctalia.settings.plugin_settings."umedbazarov/crashes".agent_cmd
  == "paseo run --provider codex/gpt-6-luna";
assert
  noctaliaHomeEvaluation.config.programs.noctalia.settings.plugin_settings."umedbazarov/crashes".terminal_cmd
  == "footclient -e";
assert
  noctaliaHomeEvaluation.config.programs.noctalia.settings.plugin_settings."avivbintangaringga/nextboot-selector".privilege_command
  == "pkexec";
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.hooks.started != "";
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.hooks.wallpaper_changed != "";
assert builtins.elem ".local/state/qnix/noctalia-wallpapers"
  hyprlandProfileEvaluation.config.qnix.persist.users."*".directories;
assert noctaliaHomeEvaluation.config.wayland.windowManager.hyprland.settings.on == [ ];
assert
  noctaliaHomeEvaluation.config.systemd.user.services.noctalia.Install.WantedBy
  == [ noctaliaHomeEvaluation.config.wayland.systemd.target ];
assert noctaliaHomeEvaluation.config.systemd.user.services.noctalia.Service.Restart == "on-failure";
assert builtins.any (
  binding:
  pkgs.lib.hasInfix "noctalia msg panel-toggle launcher" (builtins.elemAt binding._args 1).expr
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert builtins.any (
  binding: pkgs.lib.hasInfix "brightnessctl set 5%+" (builtins.elemAt binding._args 1).expr
) laptopHyprlandKeybindsEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert noctaliaHomeEvaluation.config.qnix.desktop.noctalia.settings == { };
assert
  {
    default = builtins.removeAttrs noctaliaHomeEvaluation.config.programs.noctalia.settings.bar.default [
      "center" "start" "end" "capsule_group"
    ];
  } == {
    default = {
      capsule = true;
      capsule_fill = "#073642";
      concave_edge_corners = false;
      margin_edge = 10;
      margin_ends = 20;
      position = "left";
      scale = 1.1000000089406967;
    };
  };
assert
  laptopNoctaliaHomeEvaluation.config.programs.noctalia.settings.bar
  == noctaliaHomeEvaluation.config.programs.noctalia.settings.bar;
assert
  map (
    shortcut: shortcut.type
  ) noctaliaHomeEvaluation.config.programs.noctalia.settings.control_center.shortcuts == [
    "wifi"
    "bluetooth"
    "caffeine"
    "nightlight"
    "notification"
    "clipboard"
  ];
assert !(laptopNoctaliaHomeEvaluation.config.programs.noctalia.settings ? control_center);
assert !noctaliaOverrideHomeEvaluation.config.programs.noctalia.systemd.enable;
assert !(noctaliaOverrideHomeEvaluation.config.systemd.user.services ? noctalia);
assert
  noctaliaOverrideHomeEvaluation.config.programs.noctalia.settings.shell.font_family == "Fira Sans";
assert
  noctaliaOverrideHomeEvaluation.config.programs.noctalia.settings.shell.clipboard_auto_paste
  == "off";
assert noctaliaOverrideHomeEvaluation.config.programs.noctalia.settings.shell.polkit_agent;
assert noctaliaOverrideHomeEvaluation.config.programs.noctalia.settings.lockscreen.enabled;
assert
  !noctaliaOverrideHomeEvaluation.config.programs.noctalia.settings.lockscreen.lock_before_suspend;
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.lockscreen.enabled;
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.lockscreen.lock_before_suspend;
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.lockscreen.transition == [ "honeycomb" ];
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.shell.panel.open_near_click_session;
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.shell.launch_apps_as_systemd_services;
assert noctaliaHomeEvaluation.config.programs.noctalia.settings.shell.polkit_agent;
assert !builtins.elem pkgs.hyprpolkitagent noctaliaHomeEvaluation.config.home.packages;
assert !noctaliaHomeEvaluation.config.programs.hyprlock.enable;
assert noctaliaHomeEvaluation.config.xdg.configFile ? "noctalia/config.toml";
assert displayManagerFeature.supportedEnvironments == [ "nixos" ];
assert displayManagerEvaluation.config.services.displayManager.sddm.enable;
assert displayManagerEvaluation.config.services.displayManager.sddm.theme == "sddm-astronaut-theme";
assert displayManagerEvaluation.config.services.xserver.enable;
assert noctaliaGreeterFeature.supportedEnvironments == [ "nixos" ];
assert noctaliaGreeterEvaluation.config.services.displayManager.noctalia-greeter.enable;
assert noctaliaGreeterEvaluation.config.services.greetd.enable;
assert !noctaliaGreeterEvaluation.config.services.displayManager.sddm.enable;
assert noctaliaGreeterEvaluation.config.security.pam.services.greetd.enable;
assert noctaliaGreeterEvaluation.config.security.pam.services.login.enable;
assert
  noctaliaGreeterEvaluation.config.services.displayManager.noctalia-greeter.settings.keyboard.layout
  == "de";
assert
  noctaliaGreeterEvaluation.config.services.displayManager.noctalia-greeter.settings.keyboard.variant
  == "koy";
assert
  noctaliaGreeterEvaluation.config.services.displayManager.noctalia-greeter.settings.session.default
  == "Hyprland (uwsm-managed)";
assert pkgs.lib.hasInfix "noctalia-greeter-session"
  noctaliaGreeterEvaluation.config.services.greetd.settings.default_session.command;
assert hyprlandProfileEvaluation.config.services.displayManager.noctalia-greeter.enable;
assert !hyprlandProfileEvaluation.config.services.displayManager.sddm.enable;
assert builtins.any (
  binding: pkgs.lib.hasInfix "noctalia msg session lock" (builtins.elemAt binding._args 1).expr
) hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert
  soundFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
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
  bitwardenFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.bitwarden-desktop bitwardenHomeEvaluation.config.home.packages;
assert !(builtins.elem pkgs.bitwarden-cli bitwardenHomeEvaluation.config.home.packages);
assert !(builtins.elem "noctalia/bitwarden" (
  bitwardenHomeEvaluation.config.programs.noctalia.settings.plugins.enabled or [ ]
));
assert builtins.elem pkgs.bitwarden-desktop
  bitwardenWithoutNoctaliaHomeEvaluation.config.home.packages;
assert !(builtins.elem pkgs.bitwarden-cli
  bitwardenWithoutNoctaliaHomeEvaluation.config.home.packages);
assert bitwardenNixosEvaluation.config.qnix.persist.users."*".directories == [
  ".config/Bitwarden"
];
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
assert builtins.elem pkgs.opencode-desktop opencodeHomeEvaluation.config.home.packages;
assert builtins.elem pkgs.vscode opencodeHomeEvaluation.config.home.packages;
assert builtins.elem pkgs.codex opencodeHomeEvaluation.config.home.packages;
assert
  paseoFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem "paseo" (
  map (package: package.pname or package.name) paseoHomeEvaluation.config.home.packages
);
assert builtins.elem "paseo" (
  map (package: package.pname or package.name) hyprlandStandaloneProfileEvaluation.config.home.packages
);
assert builtins.elem "paseo-desktop" (
  map (package: package.pname or package.name) paseoHomeEvaluation.config.home.packages
);
assert builtins.elem pkgs.nodejs_22 paseoHomeEvaluation.config.home.packages;
assert paseoNixosEvaluation.config.services.paseo.enable;
assert paseoNixosEvaluation.config.systemd.services.paseo.serviceConfig.User == "check";
assert
  paseoNixosEvaluation.config.systemd.services.paseo.environment.PASEO_HOME == "/home/check/.paseo";
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
assert noctaliaHomeEvaluation.config.home.sessionVariables.TERMINAL == "footclient";
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
assert builtins.elem "qnix-clipboard-history" (
  map (package: package.pname or package.name) clipboardHomeEvaluation.config.home.packages
);
assert builtins.any (
  binding: builtins.head binding._args == "SUPER + V"
) clipboardHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind;
assert
  screenshotsFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
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
    ".config/Bitwarden"
    ".codex"
    ".config/Paseo"
    ".paseo"
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
pkgs.runCommand "qnix-desktop-check"
  {
    desktopConfig = noctaliaHomeEvaluation.config.xdg.configFile."noctalia/config.toml".source;
    laptopConfig = laptopNoctaliaHomeEvaluation.config.xdg.configFile."noctalia/config.toml".source;
    overrideConfig = noctaliaOverrideHomeEvaluation.config.xdg.configFile."noctalia/config.toml".source;
    wallpaperSaveHook = noctaliaHomeEvaluation.config.programs.noctalia.settings.hooks.wallpaper_changed;
    wallpaperStartedHook = noctaliaHomeEvaluation.config.programs.noctalia.settings.hooks.started;
    noctaliaMock = pkgs.writeShellScriptBin "noctalia" ''
      printf '%s\n' "$*" >> "$HOME/noctalia-calls"
    '';
    greeterConfig =
      noctaliaGreeterEvaluation.config.systemd.tmpfiles.settings."10-noctalia-greeter"."/var/lib/noctalia-greeter/greeter.toml"."L+".argument;
  }
  ''
    test -s "$desktopConfig"
    test -s "$laptopConfig"
    test -s "$overrideConfig"
    test -s "$greeterConfig"

    export HOME="$TMPDIR/noctalia-home"
    mkdir -p "$HOME"
    export PATH="$noctaliaMock/bin:$PATH"

    eval "$wallpaperStartedHook"
    test -d "$HOME/.local/state/qnix/noctalia-wallpapers"
    test ! -e "$HOME/noctalia-calls"

    export NOCTALIA_WALLPAPER_CONNECTOR="DP-1"
    export NOCTALIA_WALLPAPER_PATH="/home/check/Wallpapers/wall paper.png"
    eval "$wallpaperSaveHook"

    savedWallpaper="$HOME/.local/state/qnix/noctalia-wallpapers/monitor-DP-1"
    IFS= read -r savedPath < "$savedWallpaper"
    test "$savedPath" = "$NOCTALIA_WALLPAPER_PATH"

    eval "$wallpaperStartedHook"
    IFS= read -r restoreCall < "$HOME/noctalia-calls"
    test "$restoreCall" = "msg wallpaper-set DP-1 $NOCTALIA_WALLPAPER_PATH"
    touch $out
  ''
