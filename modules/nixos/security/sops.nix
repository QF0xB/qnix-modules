{
  lib,
  config,
  options,
  ...
}:

let
  cfg = config.qnix.security.sops;
in
{
  config = lib.mkIf (cfg.enable && options ? sops) {
    sops = {
      defaultSopsFile = cfg.defaultSopsFile;

      age = {
        generateKey = cfg.age.generateKey;
        keyFile = cfg.age.keyFile;
      };

      secrets = lib.mapAttrs (_name: secretCfg: {
        key = secretCfg.key;
        path = secretCfg.path;
        owner = secretCfg.owner;
        group = secretCfg.group;
        mode = secretCfg.mode;
        neededForUsers = secretCfg.neededForUsers;
        restartUnits = secretCfg.restartUnits;
      }) cfg.secrets;
    };
  };
}
