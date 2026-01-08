{ lib, config, ... }:

let
  # Options can be in NixOS (system-wide, if loadOptions=true) or home-manager (via config.hm.qnix.*)
  cfg = config.qnix.core.boot or config.hm.qnix.core.boot;
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
