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
assert builtins.elem pkgs.lsd fishHomeEvaluation.config.home.packages;
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
assert
  gitFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert
  gitNixosEvaluation.config.qnix.persist.users."*".directories == [
    ".config/git"
    ".config/gh"
  ];
assert gitHomeEvaluation.config.programs.git.enable;
assert gitHomeEvaluation.config.programs.git.lfs.enable;
assert gitHomeEvaluation.config.programs.git.signing.signByDefault;
assert gitHomeEvaluation.config.programs.git.signing.key == "0123456789ABCDEF";
assert gitHomeEvaluation.config.programs.git.settings.user.name == "QNix Check";
assert gitHomeEvaluation.config.programs.git.settings.user.email == "check@example.test";
assert gitHomeEvaluation.config.programs.git.settings.push.autoSetupRemote;
assert gitHomeEvaluation.config.programs.git.settings.alias.ci == "commit";
assert gitHomeEvaluation.config.programs.gh.enable;
assert gitHomeEvaluation.config.programs.gh.settings.git_protocol == "ssh";
assert
  direnvFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert direnvNixosEvaluation.config.qnix.persist.users."*".directories == [ ".local/share/direnv" ];
assert direnvHomeEvaluation.config.programs.direnv.enable;
assert direnvHomeEvaluation.config.programs.direnv.enableFishIntegration;
assert direnvHomeEvaluation.config.programs.direnv.enableZshIntegration;
assert direnvHomeEvaluation.config.programs.direnv.nix-direnv.enable;
pkgs.runCommand "qnix-shell-check" { } "touch $out"
