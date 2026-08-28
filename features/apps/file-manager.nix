{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  home =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.nemo
        pkgs.yazi
      ];
    };
}
