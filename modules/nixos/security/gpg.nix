{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.security.gpg;
in
{
  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = cfg.enableSSH;
    };

    qnix.persist.home.directories = [ ".gnupg" ];
  };
}
