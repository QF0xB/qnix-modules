{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.qnix.system.users;

  convertUser =
    username: userCfg:
    let
      passwordConfig =
        if userCfg.passwordFromSops != null && options ? sops then
          {
            hashedPasswordFile = config.sops.secrets.${userCfg.passwordFromSops}.path;
          }
        else
          {
            initialHashedPassword = userCfg.initialHashedPassword;
          };
    in
    {
      group = if userCfg.group != null then userCfg.group else username;
      extraGroups = lib.unique (cfg.defaultExtraGroups ++ userCfg.extraGroups);
      openssh.authorizedKeys.keys = userCfg.openssh.authorizedKeys.keys;
      ignoreShellProgramCheck = userCfg.ignoreShellProgramCheck;
    }
    // lib.optionalAttrs (userCfg.home != null) {
      home = userCfg.home;
    }
    // lib.optionalAttrs (userCfg.description != null) {
      description = userCfg.description;
    }
    // passwordConfig
    // (if userCfg.kind == "system" then { isSystemUser = true; } else { isNormalUser = true; });

  renderedUsers = lib.mapAttrs convertUser cfg.users;

  renderedRoot = lib.optionalAttrs cfg.root.enable (
    let
      passwordConfig =
        if cfg.root.passwordFromSops != null && options ? sops then
          {
            hashedPasswordFile = config.sops.secrets.${cfg.root.passwordFromSops}.path;
          }
        else
          {
            initialHashedPassword = cfg.root.initialHashedPassword;
          };
    in
    {
      root = {
        isSystemUser = true;
      }
      // passwordConfig;
    }
  );

  renderedGroups = lib.foldl' (acc: groupName: acc // { ${groupName} = { }; }) { users = { }; } (
    lib.unique (lib.mapAttrsToList (_: u: u.group) renderedUsers)
  );

  shouldManage = cfg.users != { } || cfg.root.enable;
in
{
  config = lib.mkMerge [
    {
      assertions =
        [
          {
            assertion = !(cfg.root.initialHashedPassword != null && cfg.root.passwordFromSops != null);
            message = "qnix.users.root: initialHashedPassword and passwordFromSops are mutually exclusive.";
          }
        ]
        ++ lib.mapAttrsToList (username: userCfg: {
          assertion = !(userCfg.initialHashedPassword != null && userCfg.passwordFromSops != null);
          message = "qnix.users.users.${username}: initialHashedPassword and passwordFromSops are mutually exclusive.";
        }) cfg.users;
    }

    (lib.mkIf shouldManage {
      users = {
        mutableUsers = false;
        users = renderedRoot // renderedUsers;
        groups = renderedGroups;
      };
    })
  ];
}
