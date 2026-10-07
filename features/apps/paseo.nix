{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [
    ".config/Paseo"
    ".paseo"
  ];

  options =
    { lib, ... }:
    {
      user = lib.mkOption {
        type = lib.types.str;
        default = "paseo";
        description = "User account under which the Paseo daemon runs.";
      };
    };

  nixos =
    { cfg, inputs, pkgs, ... }:
    {
      services.paseo = {
        enable = true;
        user = cfg.user;
        package = inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          npmDepsHash = "sha256-4X3h5SM6xUr3kpJTPX+v3ABacDz7fS2VbJnN3/f0bkk=";
        };
      };
    };

  home =
    {
      inputs,
      pkgs,
      ...
    }:
    let
      paseoPackages = inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system};
      paseo = paseoPackages.default.override {
        npmDepsHash = "sha256-4X3h5SM6xUr3kpJTPX+v3ABacDz7fS2VbJnN3/f0bkk=";
      };
      paseoDesktop = paseoPackages.desktop.override { inherit paseo; };
    in
    {
      home.packages = [
        paseo
        paseoDesktop
        pkgs.nodejs_22
      ];
    };
}
