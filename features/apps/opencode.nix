{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "dev.mcp" ];

  persistence.users."*".directories = [ ".local/share/opencode" ];

  home = { ... }: {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
    };
  };
}
