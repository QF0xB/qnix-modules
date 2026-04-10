{ lib, config, ... }:
let
  cfg = config.qnix.desktop.xdg-folders;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".cache/dconf"
      ".config/dconf"
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Videos"
    ];
  };
}
