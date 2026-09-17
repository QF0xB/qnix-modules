{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.devenv ];
    };
}
