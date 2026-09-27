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
    {
      home.packages = with inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system}; [
        default
        desktop
      ];
    };
}
