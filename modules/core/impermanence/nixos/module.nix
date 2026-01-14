{
  lib,
  pkgs,
  config,
  user,
  ...
}:

let
  cfg = config.qnix.core.impermanence;
  persist = config.qnix.persist;

  # Create impermanence.json after environment.persistence is merged
  # Extract directory paths from impermanence's directory attribute sets
  # (impermanence converts strings to attribute sets, we need to extract the path)
  getDirPath =
    dir:
    if lib.isString dir then
      dir
    else if lib.isAttrs dir && dir ? directory then
      dir.directory
    else if lib.isAttrs dir && dir ? dirPath then
      dir.dirPath
    else
      toString dir;

  getFilePath =
    file:
    if lib.isString file then
      file
    else if lib.isAttrs file && file ? filePath then
      file.filePath
    else
      toString file;

  impermanenceJson = pkgs.writeText "impermanence.json" (
    lib.strings.toJSON {
      directories = lib.unique (
        lib.map getDirPath (
          config.environment.persistence."/persist".directories
          ++ config.environment.persistence."/cache".directories
        )
      );
      files = lib.unique (
        lib.map getFilePath (
          config.environment.persistence."/persist".files ++ config.environment.persistence."/cache".files
        )
      );
    }
  );
in
{
  config = lib.mkIf cfg.enable {
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/cache".neededForBoot = true;

    environment.persistence = {
      "/persist" = {
        hideMounts = true;
        files = lib.unique persist.root.files;
        directories = lib.unique (
          (
            if persist.root.defaultFolders then
              [
                "/var/log"
                "/var/lib/nixos"
              ]
            else
              [ ]
          )
          ++ persist.root.directories
        );

        users.${user} = {
          files = lib.unique persist.home.files;
          directories = lib.unique (
            (
              if persist.home.defaultFolders then
                [
                  "projects"
                  ".cache/dconf"
                  ".config/dconf"
                  ".ssh"
                ]
              else
                [ ]
            )
            ++ persist.home.directories
          );
        };
      };

      # Not backed up; Still persisted
      "/cache" = {
        hideMounts = true;
        files = lib.unique persist.root.cache.files;
        directories = lib.unique persist.root.cache.directories;

        users.${user} = {
          files = lib.unique persist.home.cache.files;
          directories = lib.unique persist.home.cache.directories;
        };
      };
    };

    # Use string interpolation to convert derivation to path string
    environment.etc."impermanence.json".text = "${impermanenceJson}";
  };
}
