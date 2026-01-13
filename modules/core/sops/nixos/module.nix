{
  lib,
  config,
  user ? null,
  ...
}:

let
  cfg = config.hm.qnix.core.sops;
in
{
  config = lib.mkIf cfg.enable {
    sops = {
      # Set defaultSopsFile if provided
      defaultSopsFile = lib.mkIf (cfg.defaultSopsFile != null) cfg.defaultSopsFile;

      age = {
        generateKey = cfg.age.generateKey;
        # Default keyFile to user's age key if user is available, otherwise use provided value
        keyFile =
          if cfg.age.keyFile != null then
            cfg.age.keyFile
          else if user != null then
            "/persist/home/${user}/.config/age/keys.txt"
          else
            null;
      };

      # Map qnix.core.sops.secrets.* to sops.secrets.*
      secrets = lib.mapAttrs (
        name: secretCfg:
        let
          # Build the sops secret config, filtering out null values
          sopsSecret = {
            # Use secret-specific sopsFile or fall back to defaultSopsFile
            sopsFile =
              if secretCfg.sopsFile != null then
                secretCfg.sopsFile
              else if cfg.defaultSopsFile != null then
                cfg.defaultSopsFile
              else
                null;
          }
          // lib.optionalAttrs (secretCfg.key != null) {
            key = secretCfg.key;
          }
          // lib.optionalAttrs (secretCfg.owner != null) {
            owner = secretCfg.owner;
          }
          // lib.optionalAttrs (secretCfg.group != null) {
            group = secretCfg.group;
          }
          // {
            mode = secretCfg.mode;
          }
          // lib.optionalAttrs (secretCfg.path != null) {
            path = secretCfg.path;
          }
          // lib.optionalAttrs (secretCfg.restartUnits != [ ]) {
            restartUnits = secretCfg.restartUnits;
          }
          // lib.optionalAttrs (secretCfg.reloadUnits != [ ]) {
            reloadUnits = secretCfg.reloadUnits;
          }
          // lib.optionalAttrs (secretCfg.format != null) {
            format = secretCfg.format;
          }
          // lib.optionalAttrs (secretCfg.neededBy != [ ]) {
            neededBy = secretCfg.neededBy;
          }
          // lib.optionalAttrs (secretCfg.wantedBy != [ ]) {
            wantedBy = secretCfg.wantedBy;
          }
          // lib.optionalAttrs (secretCfg.neededForUsers == true) {
            neededForUsers = true;
          };
        in
        # Filter out null values from the final config
        lib.filterAttrs (_: v: v != null) sopsSecret
      ) cfg.secrets;
    };
  };
}
