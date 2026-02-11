{ lib, config, ... }:

let
  cfg = config.qnix.core.nvf;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.home.cache.directories = [
      ".local/share/nvf"
    ];
  };
}
