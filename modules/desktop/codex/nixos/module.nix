{ lib, config, ... }:

let
  cfg = config.qnix.desktop.codex;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.home.directories = [
      ".codex"
    ];
  };
}
