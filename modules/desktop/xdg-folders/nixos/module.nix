{ lib, config, ... }:

let
  cfg = config.qnix.desktop.xdg-folders;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.home.directories = [
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Videos"
    ];
  };
}
