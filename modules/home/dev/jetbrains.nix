{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  pkgs,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.dev.jetbrains or { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = lib.concatLists [
      (lib.optionals cfg.clion.enable [ pkgs.jetbrains.clion ])
      (lib.optionals cfg.datagrip.enable [ pkgs.jetbrains.datagrip ])
      (lib.optionals cfg.dataspell.enable [ pkgs.jetbrains.dataspell ])
      (lib.optionals cfg.idea.enable [ pkgs.jetbrains.idea ])
      (lib.optionals cfg.phpstorm.enable [ pkgs.jetbrains.phpstorm ])
      (lib.optionals cfg.pycharm.enable [ pkgs.jetbrains.pycharm ])
      (lib.optionals cfg.rider.enable [ pkgs.jetbrains.rider ])
      (lib.optionals cfg.ruby-mine.enable [ pkgs.jetbrains.ruby-mine ])
      (lib.optionals cfg.rust-rover.enable [ pkgs.jetbrains.rust-rover ])
      (lib.optionals cfg.webstorm.enable [ pkgs.jetbrains.webstorm ])
    ];
  };
}
