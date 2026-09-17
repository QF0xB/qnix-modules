{
  environments = [ "nixos" ];
  optionsOnly = true;

  options =
    { lib, ... }:
    let
      assertNoHomeDirs =
        paths:
        assert
          lib.assertMsg
            (!lib.any (lib.hasPrefix "/home") paths)
            "Persistence paths must not use the /home prefix; use users.* for home-relative paths";
        paths;

      persistUserType = lib.types.submodule {
        options = {
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Directories relative to the user's home directory.";
            apply = assertNoHomeDirs;
          };

          files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Files relative to the user's home directory.";
            apply = assertNoHomeDirs;
          };

          cache = {
            directories = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Cache directories relative to the user's home directory.";
              apply = assertNoHomeDirs;
            };

            files = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Cache files relative to the user's home directory.";
              apply = assertNoHomeDirs;
            };
          };
        };
      };
    in
    {
      root = {
        directories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "System directories to persist under /persist.";
          apply = assertNoHomeDirs;
        };

        files = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "System files to persist under /persist.";
          apply = assertNoHomeDirs;
        };

        cache = {
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "System cache directories to persist under /cache.";
            apply = assertNoHomeDirs;
          };

          files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "System cache files to persist under /cache.";
            apply = assertNoHomeDirs;
          };
        };
      };

      users = lib.mkOption {
        type = lib.types.attrsOf persistUserType;
        default = { };
        description = "Per-user persistence configuration keyed by username.";
      };
    };
}
