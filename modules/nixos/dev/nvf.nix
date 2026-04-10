{ lib, config, ... }:
let
  cfg = config.qnix.dev.nvf;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".local/share/nvf"
    ];
  };
}
