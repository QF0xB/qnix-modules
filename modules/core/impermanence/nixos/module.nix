{ lib, pkgs, config, user, ... }:

let
  cfg = config.hm.qnix.core.impermanence;
  persist = config.hm.qnix.core.persist;
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
          if persist.root.defaultFolders then
            [ "/var/log" "/var/lib/nixos" ]
          else
            [ ]
          ++ persist.root.directories
        );

        users.${user} = {
          files = lib.unique persist.home.files;
          directories = lib.unique (
            if persist.home.defaultFolders then
              [ "projects" ".cache/dconf" ".config/dconf" ]
            else
              [ ]
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

    # Create impermanence.json after environment.persistence is merged
    environment.etc."impermanence.json".text = lib.mkIf cfg.enable (
      pkgs.writeText "impermanence.json" (
        lib.strings.toJSON {
          directories = lib.unique (
            config.environment.persistence."/persist".directories
            ++ config.environment.persistence."/cache".directories
          );
          files = lib.unique (
            config.environment.persistence."/persist".files 
            ++ config.environment.persistence."/cache".files
          );
        }
      )
    );
  };
}