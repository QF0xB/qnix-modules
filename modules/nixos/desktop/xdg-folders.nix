{ lib, config, ... }:
let
  cfg = config.qnix.desktop.xdg-folders;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*" = {
      directories = [
        ".config/dconf"
        "Documents"
        "Music"
        "Pictures"
        "Videos"
      ];

      cache.directories = [
        "Downloads"
      ];
    };
  };
}
