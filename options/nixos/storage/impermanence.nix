{ lib, ... }:
let
  assertNoHomeDirs =
    paths:
    assert (
      lib.assertMsg (!lib.any (lib.hasPrefix "/home") paths)
        "Paths must not use the /home prefix; use root.* for system paths or users.* as paths relative to the home directory"
    );
    paths;

  persistUserType = lib.types.submodule {
    options = {
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "projects" ];
        description = "Paths relative to the user's home directory.";
        apply = assertNoHomeDirs;
      };

      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "File paths relative to the user's home directory.";
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
  options.qnix = {
    storage.impermanence.enable = lib.mkEnableOption "impermanence";

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

      users = lib.mkOption {
        type = lib.types.attrsOf persistUserType;
        default = { };
        description = ''
          Per-user persistence config keyed by username. The special key `"*"`
          applies defaults to every managed user from `qnix.system.users.users`.

          Each user entry’s `directories` option defaults to including `projects`
          (see submodule defaults); override or extend as needed.
        '';
      };
    };
  };

  # Ensure `projects` is present even when many modules set `users."*"`.`directories`
  # (attrsOf defaults alone are skipped once any `users` definitions exist).
  config = {
    qnix.persist.users."*".directories = lib.mkBefore [ "projects" ];
  };
}
