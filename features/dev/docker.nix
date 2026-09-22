{
  environments = [ "nixos" ];

  requires.nixos = [ "system.users" ];

  nixos =
    { ... }:
    {
      virtualisation.docker.enable = true;
      qnix.system.users.defaultExtraGroups = [ "docker" ];
    };
}
