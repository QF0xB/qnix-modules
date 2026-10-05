{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [
    ".config/Bitwarden"
  ];

  options =
    { lib, pkgs, ... }:
    {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ pkgs.bitwarden-desktop ];
        description = "Bitwarden desktop application package to install.";
      };
    };

  nixos = { };

  home =
    { cfg, ... }:
    {
      home.packages = cfg.packages;
    };
}
