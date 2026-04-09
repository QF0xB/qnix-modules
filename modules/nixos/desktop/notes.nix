{ lib, config, ... }:
let
  cfg = config.qnix.desktop.notes;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".config/obsidian"
    ];
  };
}
