{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nixfmt ];
    };

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nixfmt ];
    };
}
