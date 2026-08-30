{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/BraveSoftware" ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.brave-origin ];
    };
}
