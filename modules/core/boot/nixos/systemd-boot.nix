{ lib, config, ... }:

let
  # Options can be in NixOS (system-wide, if loadOptions=true) or home-manager (via config.hm.qnix.*)
  # Check system-wide first, fallback to home-manager for flexibility (e.g., servers without home-manager)
  cfg = config.qnix.core.boot or config.hm.qnix.core.boot;
in
{
  config = lib.mkIf cfg."systemd-boot".enable {
    boot.loader.systemd-boot = {
      enable = true;
    };
  };
}

