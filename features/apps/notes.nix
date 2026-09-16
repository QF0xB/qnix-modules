{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/obsidian" ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.obsidian ];
    };
}
