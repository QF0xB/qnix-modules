{ lib, config, ... }:
let
  cfg = config.qnix.dev.jetbrains;
  anyIdeEnabled =
    cfg.clion.enable
    || cfg.datagrip.enable
    || cfg.dataspell.enable
    || cfg.idea.enable
    || cfg.phpstorm.enable
    || cfg.pycharm.enable
    || cfg.rider.enable
    || cfg.ruby-mine.enable
    || cfg.rust-rover.enable
    || cfg.webstorm.enable;
in
{
  config = lib.mkIf (cfg.enable && anyIdeEnabled) {
    qnix.persist.users."*" = {
      directories = [
        ".config/JetBrains"
        ".local/share/JetBrains"
        ".java/.userPrefs"
        ".local/share/direnv/allow"
      ];
      cache.directories = [
        ".gradle"
        ".cache/JetBrains"
      ];
    };
  };
}
