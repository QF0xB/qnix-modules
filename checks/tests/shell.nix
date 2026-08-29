{ ctx }:
with ctx;
assert
  fishFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert fishNixosEvaluation.config.programs.fish.enable;
assert fishHomeEvaluation.config.programs.fish.enable;
assert fishHomeEvaluation.config.programs.lsd.enable;
assert fishNixosEvaluation.config.qnix.persist.users."*".directories == [ ".local/share/fish" ];
assert
  shellPackagesFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert builtins.hasAttr "derivation" shellPackagesEvaluation.config.qnix.shell.packages.packages;
assert builtins.hasAttr "string" shellPackagesEvaluation.config.qnix.shell.packages.packages;
assert builtins.hasAttr "attrset" shellPackagesEvaluation.config.qnix.shell.packages.packages;
assert
  starshipFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert starshipEvaluation.config.programs.starship.enable;
assert starshipEvaluation.config.programs.starship.settings.add_newline == false;
assert starshipEvaluation.config.programs.starship.settings.format == "$directory$character";
assert
  zshFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert zshNixosEvaluation.config.programs.zsh.enable;
assert zshNixosEvaluation.config.programs.zsh.autosuggestions.enable;
assert zshNixosEvaluation.config.programs.zsh.syntaxHighlighting.enable;
assert zshNixosEvaluation.config.programs.zsh.enableCompletion;
assert zshHomeEvaluation.config.programs.zsh.enable;
assert zshHomeEvaluation.config.programs.zsh.autosuggestion.enable;
assert zshNixosEvaluation.config.qnix.persist.users."*".files == [ ".zsh_history" ];
assert builtins.hasAttr "show-root-filesystem"
  impermanenceHomeEvaluation.config.qnix.shell.packages.packages;
pkgs.runCommand "qnix-shell-check" { } "touch $out"
