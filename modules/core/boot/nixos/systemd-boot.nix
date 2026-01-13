{
  lib,
  config,
  ...
}:

let
  cfg = config.qnix.core.boot."systemd-boot";
in
{
  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot = {
      enable = true;
    };
  };
}
