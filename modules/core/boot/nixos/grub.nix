{
  lib,
  config,
  ...
}:

let
  cfg = config.qnix.core.boot.grub;
in
{
  config = lib.mkIf cfg.enable {
    boot.loader.grub = {
      enable = true;
      device = cfg.grub.device;
      efiSupport = cfg.efiSupport;
      zfsSupport = cfg.zfsSupport;
      enableCryptodisk = cfg.encrypted;
    };
  };
}
