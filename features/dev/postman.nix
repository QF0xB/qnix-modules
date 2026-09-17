{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

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
