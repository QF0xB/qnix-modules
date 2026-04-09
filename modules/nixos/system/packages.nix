{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.system.packages;
in
{
  config = lib.mkIf cfg.enable {
    fonts.packages = lib.optionals cfg.nerdFonts.enable [
      pkgs.nerd-fonts.jetbrains-mono
    ];

    environment.systemPackages = [
      cfg.editor
    ]
    ++ cfg.extra;
  };
}
