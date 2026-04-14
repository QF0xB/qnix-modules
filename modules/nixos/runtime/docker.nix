{ lib, config, ... }:
let
  cfg = config.qnix.runtime.docker;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      virtualisation.docker.enable = true;
    })

    (lib.mkIf (cfg.enable && cfg.addManagedUsersToGroup) {
      qnix.system.users.defaultExtraGroups = [ "docker" ];
    })
  ];
}
