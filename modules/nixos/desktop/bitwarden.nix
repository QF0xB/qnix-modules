{ lib, config, ... }:
let
  cfg = config.qnix.desktop.bitwarden;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".config/Bitwarden"
    ];
  };
}
