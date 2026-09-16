{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/tidal-hifi" ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.tidal-hifi ];
    };
}
