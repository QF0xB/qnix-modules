{ lib, config, ... }:
let
  cfg = config.qnix.desktop.noctalia;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*" = {
      cache.directories = [
        ".cache/noctalia"
      ];
    };
  };
}
