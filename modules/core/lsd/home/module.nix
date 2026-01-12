{ lib, config, ... }:

let
  cfg = config.qnix.core.lsd;
in
{
  config = lib.mkIf cfg.enable {
    programs.lsd = {
      enable = true;
    };
  };
}
