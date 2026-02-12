{ lib, config, ... }:

let
  cfg = config.qnix.desktop.jetbrains;
in
{
  config =
    lib.mkIf
      (
        (cfg.clion.enable)
        || (cfg.datagrip.enable)
        || (cfg.dataspell.enable)
        || (cfg.idea.enable)
        || (cfg.phpstorm.enable)
        || (cfg.pycharm.enable)
        || (cfg.rider.enable)
        || (cfg.ruby-mine.enable)
        || (cfg.rust-rover.enable)
        || (cfg.webstorm.enable)
      )
      {
        qnix.persist.home = {
          directories = [
            ".config/JetBrains"
            ".local/share/JetBrains"
            ".java/.userPrefs"
            ".gradle"
            ".local/share/direnv/allow"
          ];
          cache.directories = [
            ".cache/JetBrains"
          ];
        };
      };
}
