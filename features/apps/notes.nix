{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/obsidian" ];

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.obsidian;
        description = "Notes application package to install.";
      };
    };

  home =
    { cfg, ... }:
    {
      home.packages = [ cfg.package ];
    };
}
