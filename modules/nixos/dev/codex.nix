{ lib, config, ... }:
let
  cfg = config.qnix.dev.codex;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".codex"
    ];
  };
}
