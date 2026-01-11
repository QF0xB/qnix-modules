{ lib, pkgs, config, user, ... }:

let
  cfg = config.qnix.core.impermanence;

  impermanenceJson = pkgs.writeText "impermanence.json" (
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
  );
in
{
  config = lib.mkIf cfg.enable {
    environment.persistence = {
      "/persist" = {
        hideMounts = true;
        files = lib.unique cfg.persist.root.files;
        directories = lib.unique (
          if cfg.persist.root.defaultFolders then
            [ "/var/log" "/var/lib/nixos" ]
          else
            [ ]
          ++ cfg.persist.root.directories
        );

        users.${user} = {
          files = lib.unique cfg.persist.home.files;
          directories = lib.unique (
            if cfg.persist.home.defaultFolders then
              [ "projects" ".cache/dconf" ".config/dconf" ]
            else
              [ ]
            ++ cfg.persist.home.directories
          );
        };
      };

      # Not backed up; Still persisted
      "/cache" = {
        hideMounts = true;
        files = lib.unique cfg.persist.root.cache.files;
        directories = lib.unique cfg.persist.root.cache.directories;

        users.${user} = {
          files = lib.unique cfg.persist.home.cache.files;
          directories = lib.unique cfg.persist.home.cache.directories;
        };
      };

    environment.etc."impermanence.json".text = "${impermanenceJson}";
    };
  };
}
