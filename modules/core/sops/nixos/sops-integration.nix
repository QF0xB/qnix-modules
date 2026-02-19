# Maps qnix.core.sops → config.sops. Only load when sops-nix is in your modules;
# add after sops-nix: inputs.qnix-modules.nixosModules.qnixSopsIntegration
# Not loaded by core (avoids recursion when sops-nix is absent).
{
  lib,
  config,
  user ? null,
  ...
}:
{
  config = lib.mkIf config.qnix.core.sops.enable {
    sops = {
      defaultSopsFile = config.qnix.core.sops.defaultSopsFile;
      age = {
        generateKey = config.qnix.core.sops.age.generateKey;
        keyFile =
          if config.qnix.core.sops.age.keyFile != null then
            config.qnix.core.sops.age.keyFile
          else if user != null then
            "/persist/home/${user}/.config/age/keys.txt"
          else
            null;
      };
      secrets = lib.mapAttrs (
        name: secretCfg:
        let
          cfg = config.qnix.core.sops;
          sopsSecret = {
            sopsFile =
              if secretCfg.sopsFile != null then
                secretCfg.sopsFile
              else if cfg.defaultSopsFile != null then
                cfg.defaultSopsFile
              else
                null;
          }
          // lib.optionalAttrs (secretCfg.key != null) { key = secretCfg.key; }
          // lib.optionalAttrs (secretCfg.owner != null) { owner = secretCfg.owner; }
          // lib.optionalAttrs (secretCfg.group != null) { group = secretCfg.group; }
          // {
            mode = secretCfg.mode;
          }
          // lib.optionalAttrs (secretCfg.path != null) { path = secretCfg.path; }
          // lib.optionalAttrs (secretCfg.restartUnits != [ ]) { restartUnits = secretCfg.restartUnits; }
          // lib.optionalAttrs (secretCfg.reloadUnits != [ ]) { reloadUnits = secretCfg.reloadUnits; }
          // lib.optionalAttrs (secretCfg.format != null) { format = secretCfg.format; }
          // lib.optionalAttrs (secretCfg.neededBy != [ ]) { neededBy = secretCfg.neededBy; }
          // lib.optionalAttrs (secretCfg.wantedBy != [ ]) { wantedBy = secretCfg.wantedBy; }
          // lib.optionalAttrs (secretCfg.neededForUsers == true) { neededForUsers = true; };
        in
        lib.filterAttrs (_: v: v != null) sopsSecret
      ) config.qnix.core.sops.secrets;
    };
    qnix.persist.home.directories = [ ".config/sops/age" ];
  };
}
