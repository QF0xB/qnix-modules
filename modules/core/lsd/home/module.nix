{ lib, osConfig, ... }:

let
  cfg = osConfig.qnix.core.lsd;
in
{
  config = lib.mkIf cfg.enable {
    programs.lsd = {
      enable = true;
    };
  };
}
