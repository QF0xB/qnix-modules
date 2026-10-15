{
  environments = [ "nixos" ];

  requires.nixos = [ "system.users" ];

  nixos =
    { ... }:
    {
      virtualisation.docker = {
        enable = true;
        logDriver = "local";
      };
      qnix.system.users.defaultExtraGroups = [ "docker" ];
    };
}
