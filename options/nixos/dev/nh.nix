{ lib, ... }:
{
  options.qnix.dev.nh = {
    enable = lib.mkEnableOption "nh";

    clean = {
      enable = lib.mkEnableOption "periodic nh clean user garbage collection";

      dates = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "weekly";
        description = "How often to run nh clean.";
      };
    };
  };
}
