{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/obs-studio" ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.obs-studio ];
    };
}
