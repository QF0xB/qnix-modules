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
    "qnix-signed-commit"
    "qnix-dev-modules"
    "qnix-use-release"
    "qnix-sync-modules"
    "qnix-release"
  ];
assert developerHomeProfileEvaluation.config.programs.nvf.enable;
assert developerHomeProfileEvaluation.config.programs.git.enable;
assert builtins.all
  (path: builtins.elem path developerProfileEvaluation.config.qnix.persist.users."*".directories)
  [
    ".agentsview"
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
