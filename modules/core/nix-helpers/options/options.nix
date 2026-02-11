{ lib, ... }:

{
  options.qnix.core.nix-helpers = {
    nh = {
      enable = lib.mkEnableOption "nh" // {
        default = true;
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
        default = true;
        description = "Whether to install nixfmt.";
      };
    };

    direnv = {
      enable = lib.mkEnableOption "direnv" // {
        default = true;
        description = "Whether to install direnv.";
      };
    };
  };
}
