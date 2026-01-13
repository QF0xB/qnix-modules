{ lib, config, ... }:

let
  # Get config from home-manager (options only exist there)
  cfg = config.qnix.core.user;

  # Convert user config to NixOS format
  convertUser =
    username: userCfg:
    let
      baseConfig = {
        group = userCfg.group or username;
        home = userCfg.home;
        description = userCfg.description;
        extraGroups = lib.unique (cfg.defaultExtraGroups ++ (userCfg.extraGroups or [ ]));
        openssh.authorizedKeys.keys = userCfg.openssh.authorizedKeys.keys or [ ];
        ignoreShellProgramCheck = userCfg.ignoreShellProgramCheck or true;
      };
      # If passwordFromSops is set, use hashedPasswordFile; otherwise use initialHashedPassword
      passwordConfig =
        if userCfg.passwordFromSops != null then
          { hashedPasswordFile = config.sops.secrets.${userCfg.passwordFromSops}.path; }
        else
          { initialHashedPassword = userCfg.initialHashedPassword; };
    in
    baseConfig
    // passwordConfig
    // (if userCfg.isSystemUser or false then { isSystemUser = true; } else { isNormalUser = true; });

  # Convert all users
  users = lib.mapAttrs convertUser cfg.users;

  # Root user
  rootUser = lib.optionalAttrs cfg.root.enable (
    let
      passwordConfig =
        if cfg.root.passwordFromSops != null then
          { hashedPasswordFile = config.sops.secrets.${cfg.root.passwordFromSops}.path; }
        else
          { initialHashedPassword = cfg.root.password; };
    in
    {
      root = {
        isSystemUser = true;
      }
      // passwordConfig;
    }
  );

  # Groups (primary groups for each user + users group)
  groups = lib.foldl' (acc: name: acc // { ${name} = { }; }) { users = { }; } (
    lib.unique (lib.mapAttrsToList (n: u: u.group) users)
  );
in
{
  config = lib.mkIf cfg.enable {
    users = {
      mutableUsers = false;
      users = rootUser // users;
      groups = groups;
    };
  };
}
