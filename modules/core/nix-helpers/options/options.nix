{ lib, ... }:

{
  options.qnix.core.nix-helpers = {
    enable = lib.mkEnableOption "nix-helpers (nh, nixfmt, and related Nix CLI helpers)" // {
      default = false;
    };

    nh = {
      enable = lib.mkEnableOption "nh" // { 
        default = true; 
      };

      flake = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.singleLineStr lib.types.path);
        default = null;
        description = ''
          Default flake for nh (FLAKE / NH_FLAKE).
          Used by nh os switch, nh home switch, etc.
        '';
      };

      osFlake = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.singleLineStr lib.types.path);
        default = null;
        description = "Flake for nh os actions (NH_OS_FLAKE). Overrides flake for nh os.";
      };

      homeFlake = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.singleLineStr lib.types.path);
        default = null;
        description = "Flake for nh home actions (NH_HOME_FLAKE). Overrides flake for nh home.";
      };

      clean = {
        enable = lib.mkEnableOption "periodic nh clean user (garbage collection)" // { 
          default = true; 
        };
        dates = lib.mkOption { 
          type = lib.types.singleLineStr; 
          default = "weekly"; 
          description = "How often to run nh clean (systemd timer calendar)."; 
        };
        extraArgs = lib.mkOption { 
          type = lib.types.singleLineStr; 
          default = ""; 
          example = "--keep 5 --keep-since 3d"; 
          description = "Extra arguments passed to nh clean."; 
          };
      };
    };

    nixfmt = {
      enable = lib.mkEnableOption "nixfmt" // {
        default = false;
        description = "Whether to install nixfmt.";
      };
    };
  };
}
