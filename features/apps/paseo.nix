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

  home =
    {
      inputs,
      pkgs,
      ...
    }:
    let
      paseoPackages = inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system};
      paseo = paseoPackages.default.override {
        npmDepsHash = "sha256-UXnB6q5tubKpTs+A5+u/NLSzc8ZK6rAsQs+kEphEKd8=";
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
