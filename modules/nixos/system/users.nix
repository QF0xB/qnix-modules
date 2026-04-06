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
      group = userCfg.group or username;
      home = userCfg.home;
      description = userCfg.description;
      extraGroups = lib.unique (cfg.defaultExtraGroups ++ userCfg.extraGroups);
      openssh.authorizedKeys.keys = userCfg.openssh.authorizedKeys.keys;
      ignoreShellProgramCheck = userCfg.ignoreShellProgramCheck;
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
  options.qnix.system.users = {
    defaultExtraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Groups added to all managed normal users.";
    };

    root = {
      enable = lib.mkEnableOption "root user management";

      initialHashedPassword = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Initial hashed password for root.";
      };

      passwordFromSops = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "SOPS secret name containing the root hashed password.";
      };
    };

    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            kind = lib.mkOption {
              type = lib.types.enum [
                "normal"
                "system"
              ];
              default = "normal";
            };

            group = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            home = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            description = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            extraGroups = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            initialHashedPassword = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            passwordFromSops = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };

            openssh.authorizedKeys.keys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            ignoreShellProgramCheck = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
          };
        }
      );
      default = { };
    };
  };

  assertions = [
    {
      assertion = !(cfg.root.initialHashedPassword != null && cfg.root.passwordFromSops != null);
      message = "qnix.users.root: initialHashedPassword and passwordFromSops are mutually exclusive.";
    }
  ]
  ++ lib.mapAttrsToList (username: userCfg: {
    assertion = !(userCfg.initialHashedPassword != null && userCfg.passwordFromSops != null);
    message = "qnix.users.users.${username}: initialHashedPassword and passwordFromSops are mutually exclusive.";
  }) cfg.users;

  config = lib.mkIf shouldManage {
    users = {
      mutableUsers = false;
      users = renderedRoot // renderedUsers;
      groups = renderedGroups;
    };
  };
}
