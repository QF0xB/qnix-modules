{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/obs-studio" ];

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.obs-studio;
        description = "OBS Studio package to install.";
      };
    };

  home =
    { cfg, ... }:
    {
      home.packages = [ cfg.package ];
    };
}
