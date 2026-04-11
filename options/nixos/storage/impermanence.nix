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
        default = [ ];
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
          default = [ ];
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

          Baseline persisted user directories are injected by this module's
          `config` using list merging, so other modules can extend them without
          replacing them.
        '';
      };
    };
  };

  # Provide baseline persisted paths as merged config values rather than option
  # defaults, so feature modules can extend them without replacing them.
  config = {
    qnix.persist.root.directories = lib.mkBefore [
      "/var/lib/nixos"
    ];

    qnix.persist.root.cache.directories = lib.mkBefore [
      "/var/log"
      "/var/log/journal"
    ];

    qnix.persist.users."*" = {
      directories = lib.mkBefore [
        "projects"
        ".ssh"
      ];

      cache.directories = lib.mkBefore [
        ".cache"
        ".gradle"
      ];
    };
  };
}
