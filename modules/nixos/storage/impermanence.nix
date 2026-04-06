# Impermanence integration for QNix.
#
# Enable with `qnix.storage.impermanence.enable` (see `modules/shared/qnix-options.nix`).
# Path lists live under `qnix.persist.{root,home}` (this file defines those options).
#
# Module argument `user`:
# - `null` (default): only system paths under `/persist` and `/cache` are configured; no
#   `environment.persistence.*.users` entries. Use for headless hosts or when home is
#   managed elsewhere.
# - A string username: expands `qnix.persist.home` paths under `/home/<user>/` and adds
#   per-user persistence. Pass via the module import, e.g.:
#     imports = [ (import ./impermanence.nix { user = "alice"; }) ];
#   or from a profile that sets `_module.args.user` / `specialArgs` for that import.
#
{
  lib,
  config,
  pkgs,
  user ? null,
  ...
}:

let
  assertNoHomeDirs =
    paths:
    assert (
      lib.assertMsg (!lib.any (lib.hasPrefix "/home") paths)
        "Paths must not use the /home prefix; use root.* for system paths or home.* as paths relative to the home directory"
    );
    paths;
in
{
  options = {
    qnix = {
      persist = {
        root = {
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "/var/log"
              "/var/lib/nixos"
            ];
            description = "System directories to bind under /persist (must not be under /home).";
            apply = assertNoHomeDirs;
          };
          files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "System files to bind under /persist (must not be under /home).";
            apply = assertNoHomeDirs;
          };

          cache = {
            directories = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "System cache directories under /cache (must not be under /home).";
              apply = assertNoHomeDirs;
            };
            files = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "System cache files under /cache (must not be under /home).";
              apply = assertNoHomeDirs;
            };
          };
        };

        home = {
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Paths relative to the home directory (or absolute under that home only). Must not start with /home; use .config/foo not /home/user/.config.";
            apply = assertNoHomeDirs;
          };
          files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Same as home.directories, for files.";
            apply = assertNoHomeDirs;
          };
          cache = {
            directories = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Home-relative cache paths, persisted under /cache.";
              apply = assertNoHomeDirs;
            };
            files = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Home-relative cache files, persisted under /cache.";
              apply = assertNoHomeDirs;
            };
          };
        };
      };
    };
  };

  config = lib.mkIf config.qnix.storage.impermanence.enable (
    let
      cfg = config.qnix.persist;

      rootDirs = cfg.root.directories ++ cfg.root.cache.directories;
      rootFiles = cfg.root.files ++ cfg.root.cache.files;

      homeDirs = cfg.home.directories ++ cfg.home.cache.directories;
      homeFiles = cfg.home.files ++ cfg.home.cache.files;

      homeDirPaths =
        if user != null then
          lib.unique (
            lib.map (
              d:
              "/home/${user}/"
              + (if lib.hasPrefix "/" (toString d) then lib.removePrefix "/" (toString d) else toString d)
            ) homeDirs
          )
        else
          [ ];
      homeFilePaths =
        if user != null then
          lib.unique (
            lib.map (
              f:
              "/home/${user}/"
              + (if lib.hasPrefix "/" (toString f) then lib.removePrefix "/" (toString f) else toString f)
            ) homeFiles
          )
        else
          [ ];

      impermanenceJson = pkgs.writeText "impermanence.json" (
        builtins.toJSON {
          directories = lib.unique (rootDirs ++ homeDirPaths);
          files = lib.unique (rootFiles ++ homeFilePaths);
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

          users = lib.mkIf (user != null) {
            ${user} = {
              files = cfg.home.files;
              directories = cfg.home.directories;
            };
          };
        };
        "/cache" = {
          hideMounts = true;
          files = cfg.root.cache.files;
          directories = cfg.root.cache.directories;

          users = lib.mkIf (user != null) {
            ${user} = {
              files = cfg.home.cache.files;
              directories = cfg.home.cache.directories;
            };
          };
        };
      };

      environment.etc."impermanence.json".source = impermanenceJson;
    }
  );
}
