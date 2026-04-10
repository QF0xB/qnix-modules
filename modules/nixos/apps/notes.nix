{ lib, config, ... }:
let
  cfg = config.qnix.apps.notes;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".config/obsidian"
    ];
  };
}
