{ lib, config, pkgs, ... }:

let
  cfg = config.qnix.core.gpg;
in
{
  config = lib.mkIf cfg.enable {
    # Ensure GPG is available system-wide
    # Main configuration is handled by Home Manager to avoid conflicts
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = cfg.enableSSH;
    };
  };
}
