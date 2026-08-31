{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "dev.mcp" ];

  persistence.users."*".directories = [
    ".config/opencode/skills"
    ".local/share/opencode"
  ];

  home =
    { pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
        enableMcpIntegration = true;
      };
    };
}
