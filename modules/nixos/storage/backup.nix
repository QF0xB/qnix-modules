{
  lib,
  config,
  pkgs,
  options,
  ...
}:
let
  cfg = config.qnix.storage.backup;

  mkPassCommand =
    targetCfg:
    if targetCfg.encryption.passCommand != null then
      targetCfg.encryption.passCommand
    else if
      targetCfg.encryption.sopsSecretName != null
      && options ? sops
      && lib.hasAttrByPath [ "secrets" targetCfg.encryption.sopsSecretName ] config.sops
    then
      "${pkgs.coreutils}/bin/cat ${config.sops.secrets.${targetCfg.encryption.sopsSecretName}.path}"
    else
      null;

  mkJob =
    name: targetCfg:
    let
      passCommand = mkPassCommand targetCfg;
      sshEnv =
        if targetCfg ? sshKeyPath && targetCfg.sshKeyPath != null then
          {
            BORG_RSH =
              "ssh -i ${targetCfg.sshKeyPath} -o BatchMode=yes -o IdentitiesOnly=yes"
              + lib.optionalString (
                targetCfg ? sshKnownHostsFile && targetCfg.sshKnownHostsFile != null
              ) " -o UserKnownHostsFile=${targetCfg.sshKnownHostsFile}";
          }
        else
          { };
    in
    {
      inherit (cfg) paths exclude compression persistentTimer inhibitsSleep;
      repo = targetCfg.repo;
      startAt = if targetCfg.startAt != null then targetCfg.startAt else cfg.startAt;
      doInit = targetCfg.doInit;
      extraCreateArgs = if targetCfg.extraCreateArgs != "" then targetCfg.extraCreateArgs else cfg.extraCreateArgs;
      readWritePaths = targetCfg.readWritePaths;
      preHook = targetCfg.preHook;
      environment = targetCfg.environment // sshEnv;
      encryption = {
        mode = targetCfg.encryption.mode;
        inherit passCommand;
      };
      prune.keep = if targetCfg.prune.keep != { } then targetCfg.prune.keep else cfg.prune.keep;
    };

  borgTargets = cfg.targets.borg;
  nfsTargets = cfg.targets.nfs;

  borgJobs = lib.mapAttrs (_: targetCfg: mkJob "borg" targetCfg) (lib.filterAttrs (_: t: t.enable) borgTargets);
  nfsJobs = lib.mapAttrs (_: targetCfg: mkJob "nfs" targetCfg) (lib.filterAttrs (_: t: t.enable) nfsTargets);

  nfsMounts = lib.mapAttrs'
    (_: targetCfg:
      lib.nameValuePair targetCfg.mount.where {
        device = targetCfg.mount.what;
        fsType = "nfs";
        options = targetCfg.mount.options;
      })
    (lib.filterAttrs (_: t: t.enable && t.mount.enable) nfsTargets);

  borgAssertions =
    lib.mapAttrsToList
      (name: targetCfg: {
        assertion = !targetCfg.enable || targetCfg.repo != null;
        message = "qnix.storage.backup.targets.borg.${name}.repo must be set when the target is enabled.";
      })
      borgTargets
    ++ lib.mapAttrsToList
      (name: targetCfg: {
        assertion = !targetCfg.enable || targetCfg.encryption.mode == "none" || mkPassCommand targetCfg != null;
        message = "qnix.storage.backup.targets.borg.${name} requires encryption.passCommand or encryption.sopsSecretName unless encryption.mode = \"none\".";
      })
      borgTargets;

  nfsAssertions =
    lib.mapAttrsToList
      (name: targetCfg: {
        assertion = !targetCfg.enable || targetCfg.repo != null;
        message = "qnix.storage.backup.targets.nfs.${name}.repo must be set when the target is enabled.";
      })
      nfsTargets
    ++ lib.mapAttrsToList
      (name: targetCfg: {
        assertion = !targetCfg.enable || !targetCfg.mount.enable || targetCfg.mount.what != null;
        message = "qnix.storage.backup.targets.nfs.${name}.mount.what must be set when the NFS target mount is enabled.";
      })
      nfsTargets
    ++ lib.mapAttrsToList
      (name: targetCfg: {
        assertion = !targetCfg.enable || targetCfg.encryption.mode == "none" || mkPassCommand targetCfg != null;
        message = "qnix.storage.backup.targets.nfs.${name} requires encryption.passCommand or encryption.sopsSecretName unless encryption.mode = \"none\".";
      })
      nfsTargets;
in
{
  config = lib.mkIf cfg.enable {
    assertions = borgAssertions ++ nfsAssertions;

    fileSystems = nfsMounts;

    services.borgbackup.jobs = borgJobs // nfsJobs;
  };
}
