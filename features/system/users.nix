{
  environments = [ "nixos" ];

  options =
    {
      lib,
      pkgs,
      ...
    }:
    {
      defaultExtraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Groups added to all managed normal users.";
      };

      defaultShell = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "bash" "fish" "zsh" ]);
        default = null;
        description = "Default login shell for managed users.";
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
                type = lib.types.enum [ "normal" "system" ];
                default = "normal";
                description = "Whether this is a normal login user or a system user.";
              };

              group = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };

              home = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };

              shell = lib.mkOption {
                type = lib.types.nullOr (lib.types.enum [ "bash" "fish" "zsh" ]);
                default = null;
                description = "Login shell for this user; null uses the system default.";
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
        description = "Declarative system and login users.";
      };
    };

  nixos =
    {
      config,
      lib,
      options,
      cfg,
      pkgs,
      ...
    }:
    let
      passwordConfig =
        username: userCfg:
        if userCfg.passwordFromSops != null && options ? sops then
          {
            hashedPasswordFile = config.sops.secrets.${userCfg.passwordFromSops}.path;
          }
        else
          {
            initialHashedPassword = userCfg.initialHashedPassword;
          };

      shellPackages = {
        bash = pkgs.bash;
        fish = pkgs.fish;
        zsh = pkgs.zsh;
      };

      convertUser =
        username: userCfg:
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
        // lib.optionalAttrs (userCfg.shell != null) {
          shell = shellPackages.${userCfg.shell};
        }
        // passwordConfig username userCfg
        // (if userCfg.kind == "system" then { isSystemUser = true; } else { isNormalUser = true; });

      renderedUsers = lib.mapAttrs convertUser cfg.users;
      renderedRoot = lib.optionalAttrs cfg.root.enable (
        {
          root = {
            isSystemUser = true;
          } // passwordConfig "root" cfg.root;
        }
      );
      renderedGroups = lib.genAttrs
        (lib.unique (
          lib.mapAttrsToList (
            username: userCfg:
            if userCfg.group != null then userCfg.group else username
          ) cfg.users
        ))
        (_: { });
      shouldManage = cfg.users != { } || cfg.root.enable;
    in
    {
      assertions = [
        {
          assertion = !(cfg.root.initialHashedPassword != null && cfg.root.passwordFromSops != null);
          message = "qnix.system.users.root: initialHashedPassword and passwordFromSops are mutually exclusive.";
        }
        {
          assertion = cfg.root.passwordFromSops == null || options ? sops;
          message = "qnix.system.users.root: passwordFromSops requires the SOPS NixOS options.";
        }
      ] ++ lib.concatLists (lib.mapAttrsToList (username: userCfg: [
        {
          assertion = !(userCfg.initialHashedPassword != null && userCfg.passwordFromSops != null);
          message = "qnix.system.users.users.${username}: initialHashedPassword and passwordFromSops are mutually exclusive.";
        }
        {
          assertion = userCfg.passwordFromSops == null || options ? sops;
          message = "qnix.system.users.users.${username}: passwordFromSops requires the SOPS NixOS options.";
        }
      ]) cfg.users);

      users = lib.mkIf shouldManage {
        mutableUsers = false;
        defaultUserShell = lib.mkIf (cfg.defaultShell != null) shellPackages.${cfg.defaultShell};
        users = renderedRoot // renderedUsers;
        groups = renderedGroups;
      };
    };
}
