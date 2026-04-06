# Impermanence integration for QNix.
#
# Enable with `qnix.storage.impermanence.enable`.
# Path lists live under `qnix.persist.{root,users}` (this file defines those options).
# `qnix.persist.users` is keyed by username and may also contain `"*"` defaults that are
# merged into every managed user from `qnix.system.users.users`.
#
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.persist;
  usersCfg = config.qnix.system.users.users;

  assertNoHomeDirs =
    paths:
    assert (
      lib.assertMsg (!lib.any (lib.hasPrefix "/home") paths)
        "Paths must not use the /home prefix; use root.* for system paths or home.* as paths relative to the home directory"
    );
    paths;

  wildcardUserCfg = cfg.users."*" or { };

  mergeUserPersist =
    username:
    let
      specific = cfg.users.${username} or { };
      merged = lib.recursiveUpdate wildcardUserCfg specific;
    in
    {
      files = lib.unique ((merged.files or [ ]) ++ (merged.cache.files or [ ]));
      directories = lib.unique ((merged.directories or [ ]) ++ (merged.cache.directories or [ ]));
      persistFiles = merged.files or [ ];
      persistDirectories = merged.directories or [ ];
      cacheFiles = merged.cache.files or [ ];
      cacheDirectories = merged.cache.directories or [ ];
      expandedFiles = lib.unique (
        lib.map
          (f: "/home/${username}/" + (if lib.hasPrefix "/" (toString f) then lib.removePrefix "/" (toString f) else toString f))
          ((merged.files or [ ]) ++ (merged.cache.files or [ ]))
      );
      expandedDirectories = lib.unique (
        lib.map
          (d: "/home/${username}/" + (if lib.hasPrefix "/" (toString d) then lib.removePrefix "/" (toString d) else toString d))
          ((merged.directories or [ ]) ++ (merged.cache.directories or [ ]))
      );
    };

  managedPersistUsers = lib.genAttrs (lib.attrNames usersCfg) mergeUserPersist;
in
{
  config = lib.mkIf config.qnix.storage.impermanence.enable (
    let
      rootDirs = cfg.root.directories ++ cfg.root.cache.directories;
      rootFiles = cfg.root.files ++ cfg.root.cache.files;

      impermanenceJson = pkgs.writeText "impermanence.json" (
        builtins.toJSON {
          directories = lib.unique (
            rootDirs
            ++ lib.concatMap (userCfg: userCfg.expandedDirectories) (lib.attrValues managedPersistUsers)
          );
          files = lib.unique (
            rootFiles
            ++ lib.concatMap (userCfg: userCfg.expandedFiles) (lib.attrValues managedPersistUsers)
          );
        }
      );
    in
    {
      fileSystems."/persist".neededForBoot = true;
      fileSystems."/cache".neededForBoot = true;

      environment.persistence = {
        "/persist" = {
          hideMounts = true;
          files = lib.unique (cfg.root.files ++ cfg.root.cache.files);
          directories = lib.unique (cfg.root.directories ++ cfg.root.cache.directories);

          users = lib.mapAttrs (_: userCfg: {
            files = userCfg.persistFiles;
            directories = userCfg.persistDirectories;
          }) managedPersistUsers;
        };
        "/cache" = {
          hideMounts = true;
          files = cfg.root.cache.files;
          directories = cfg.root.cache.directories;

          users = lib.mapAttrs (_: userCfg: {
            files = userCfg.cacheFiles;
            directories = userCfg.cacheDirectories;
          }) managedPersistUsers;
        };
      };

      environment.etc."impermanence.json".source = impermanenceJson;
    }
  );
}
