{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "shell.fish" ];

  persistence.users."*".directories = [ ".local/share/direnv" ];

  nixos =
    { ... }:
    { };

  home =
    { ... }:
    {
      programs.direnv = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
}
