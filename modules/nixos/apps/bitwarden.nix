{ lib, config, ... }:
let
  cfg = config.qnix.apps.bitwarden;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".config/Bitwarden"
    ];
  };
}
