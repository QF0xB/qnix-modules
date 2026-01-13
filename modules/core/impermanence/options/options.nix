{ lib, ... }:

let
  assertNoHomeDirs =
    paths:
    assert (lib.assertMsg (!lib.any (lib.hasPrefix "/home") paths) "/home used in a root persist!");
    paths;
in
{
  options.qnix = {
    core.impermanence = {
      enable = lib.mkEnableOption "impermanence" // {
        default = false;
      };
    };

    persist = {
      root = {
        defaultFolders = lib.mkEnableOption "default folders" // {
          default = true;
        };

        directories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "/var/log"
            "/var/lib/nixos"
          ];
          apply = assertNoHomeDirs;
          description = "Directories to persist in root filesystem";
        };

        files = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          apply = assertNoHomeDirs;
          description = "Files to persist in root filesystem";
        };

        cache = {
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            apply = assertNoHomeDirs;
            description = "Directories to cache in root filesystem";
          };

          files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            apply = assertNoHomeDirs;
            description = "Files to cache in root filesystem";
          };
        };
      };

      home = {
        defaultFolders = lib.mkEnableOption "default folders" // {
          default = true;
        };

        directories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Directories to persist in home filesystem";
        };

        files = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Files to persist in home filesystem";
        };

        cache = {
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Directories to cache in home filesystem";
          };

          files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Files to cache in home filesystem";
          };
        };
      };
    };
  };
}
