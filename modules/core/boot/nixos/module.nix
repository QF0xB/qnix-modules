{
  lib,
  config,
  ...
}:

let
  cfg = config.qnix.core.boot;
in
{
  imports = [
    ./common.nix
    ./grub.nix
    ./systemd-boot.nix
  ];

  # Ensure only one bootloader is enabled
  assertions = [
    {
      assertion = !(cfg.grub.enable && cfg."systemd-boot".enable);
      message = "Only one bootloader can be enabled at a time. Choose either grub or systemd-boot.";
    }
  ];
}
