{ ctx }:
with ctx;
assert
  fontsFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.nerd-fonts.jetbrains-mono fontsNixosEvaluation.config.fonts.packages;
assert builtins.elem pkgs.nerd-fonts.jetbrains-mono fontsHomeEvaluation.config.home.packages;
assert
  stylixFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert stylixNixosEvaluation.config.stylix.enable;
assert stylixNixosEvaluation.config.stylix.polarity == "dark";
assert stylixNixosEvaluation.config.stylix.cursor.name == "Simp1e-Solarized-Dark";
assert stylixHomeEvaluation.config.stylix.enable;
assert stylixHomeEvaluation.config.stylix.targets.foot.enable;
pkgs.runCommand "qnix-appearance-check" { } "touch $out"
