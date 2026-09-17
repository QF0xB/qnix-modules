{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/Postman" ];

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.postman;
        description = "Postman package to install.";
      };
    };

  home =
    { cfg, ... }:
    {
      home.packages = [ cfg.package ];
    };
}
