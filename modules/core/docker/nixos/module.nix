{ lib, config, ... }:

let
  cfg = config.qnix.core.docker;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
    };

    qnix = {
      core.user.defaultExtraGroups = [
        "docker"
      ];
    };
  };
}
