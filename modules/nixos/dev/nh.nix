{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.dev.nh;
in
{
  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean = {
        enable = cfg.clean.enable;
        dates = cfg.clean.dates;
      };
    };
  };
}
