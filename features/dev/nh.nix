{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      clean = {
        enable = lib.mkEnableOption "periodic nh clean garbage collection";

        dates = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "weekly";
          description = "How often nh runs garbage collection.";
        };
      };
    };

  nixos =
    { cfg, ... }:
    {
      programs.nh = {
        enable = true;
        clean = {
          enable = cfg.clean.enable;
          dates = cfg.clean.dates;
        };
      };
    };
}
