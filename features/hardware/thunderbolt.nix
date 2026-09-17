{
  environments = [ "nixos" ];

  options =
    { lib, ... }:
    {
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Optional Bolt package override.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      ...
    }:
    {
      services.hardware.bolt = lib.mkMerge [
        { enable = true; }
        (lib.mkIf (cfg.package != null) { package = cfg.package; })
      ];
    };
}
