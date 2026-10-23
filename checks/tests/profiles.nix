{ ctx }:
with ctx;
assert impermanenceProfileEvaluation.config.qnix.storage.impermanence.enable;
assert impermanenceProfileEvaluation.config.qnix.persist.root.directories == [ "/var/lib/nixos" ];
assert defaultEvaluation.config.qnix.system.localisation.enable;
assert
  defaultEvaluation.config.qnix.appearance.fonts.packages == [ pkgs.nerd-fonts.jetbrains-mono ];
assert defaultEvaluation.config.qnix.system.users.defaultExtraGroups == [ "wheel" ];
assert defaultEvaluation.config.qnix.system.users.defaultShell == "fish";
assert defaultEvaluation.config.qnix.network.addressing.enable;
assert workstationProfileEvaluation.config.qnix.hardware.bluetooth.enable;
assert workstationProfileEvaluation.config.qnix.hardware.thunderbolt.enable;
assert workstationProfileEvaluation.config.qnix.network.networkmanager.enable;
assert hyprlandProfileEvaluation.config.boot.plymouth.enable;
assert laptopProfileEvaluation.config.qnix.hardware.laptop.enable;
assert laptopProfileEvaluation.config.qnix.hardware.power-management.enable;
assert defaultEvaluation.config.programs.fish.enable;
assert defaultEvaluation.config.programs.zsh.enable;
assert shellHomeProfileEvaluation.config.programs.starship.enable;
assert builtins.all
  (
    name:
    builtins.elem name (
      map (package: package.pname or package.name) shellHomeProfileEvaluation.config.home.packages
    )
  )
  [
    "qnix-dev-modules"
    "qnix-use-release"
    "qnix-sync-modules"
    "qnix-release"
  ];
assert developerHomeProfileEvaluation.config.programs.nvf.enable;
assert developerHomeProfileEvaluation.config.programs.git.enable;
assert developerHomeProfileEvaluation.config.programs.claude-code.enable;
assert developerHomeProfileEvaluation.config.programs.claude-code.enableMcpIntegration;
assert
  developerHomeProfileEvaluation.config.programs.claude-code.settings.attribution == {
    commit = "";
    pr = "";
    sessionUrl = false;
  };
assert builtins.hasAttr "git-signing"
  developerHomeProfileEvaluation.config.programs.claude-code.skills;
assert builtins.all
  (plugin: builtins.hasAttr plugin developerHomeProfileEvaluation.config.programs.claude-code.plugins)
  [
    "caveman"
    "mattpocock-skills"
  ];
assert builtins.hasAttr "aislop" developerHomeProfileEvaluation.config.programs.claude-code.rules;
assert
  (builtins.head developerHomeProfileEvaluation.config.programs.claude-code.settings.hooks.PostToolUse)
  .matcher == "Edit|Write|MultiEdit";
assert
  (builtins.head developerHomeProfileEvaluation.config.programs.claude-code.settings.hooks.PreToolUse)
  .matcher == "Bash";
assert builtins.hasAttr "codex-delegate"
  developerHomeProfileEvaluation.config.programs.claude-code.skills;
assert builtins.hasAttr "plannotator"
  developerHomeProfileEvaluation.config.programs.claude-code.plugins;
assert builtins.hasAttr "context7" developerHomeProfileEvaluation.config.programs.mcp.servers;
assert builtins.elem ".claude.json" developerProfileEvaluation.config.qnix.persist.users."*".files;
assert developerProfileEvaluation.config.virtualisation.docker.enable;
assert developerProfileEvaluation.config.virtualisation.docker.logDriver == "local";
assert builtins.elem "docker"
  developerProfileEvaluation.config.qnix.system.users.defaultExtraGroups;
assert builtins.all
  (path: builtins.elem path developerProfileEvaluation.config.qnix.persist.users."*".directories)
  [
    ".agentsview"
    ".claude"
    ".config/Code"
    ".ctx"
    ".vscode/extensions"
    ".local/share/nvf"
  ];
assert defaultEvaluation.config.time.timeZone == "Europe/Berlin";
assert defaultEvaluation.config.services.xserver.xkb.layout == "de";
assert defaultEvaluation.config.services.xserver.xkb.variant == "koy";
assert defaultEvaluation.config.console.useXkbConfig;
assert overrideEvaluation.config.time.timeZone == "UTC";
assert overrideEvaluation.config.services.xserver.xkb.layout == "us";
pkgs.runCommand "qnix-profiles-check" { } "touch $out"
