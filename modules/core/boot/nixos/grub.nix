{ lib, config, ... }:

let
  # Options can be in NixOS (system-wide, if loadOptions=true) or home-manager (via config.hm.qnix.*)
  # Check system-wide first, fallback to home-manager for flexibility (e.g., servers without home-manager)
  cfg = config.qnix.core.boot.grub or config.hm.qnix.core.boot.grub;
in
{
  config = lib.mkIf cfg.enable {
    boot = {
      loader = {
        grub = {
          enable = true;
        };
      };
    };
  };
}