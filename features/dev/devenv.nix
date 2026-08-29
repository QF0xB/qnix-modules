{
  environments = [ "nixos" ];

  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.devenv ];
    };
}
