{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "dev.mcp" ];

  persistence.users."*".directories = [ ".local/share/opencode" ];

  home =
    { pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
        extraPackages = with pkgs.llm-agents; [
          codegraph
          gitnexus
          qmd
          rtk
          skills
        ];
        enableMcpIntegration = true;
      };
    };
}
