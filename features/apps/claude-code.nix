{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "dev.mcp" ];

  persistence.users."*" = {
    directories = [ ".claude" ];
    files = [ ".claude.json" ];
  };

  home =
    { pkgs, ... }:
    {
      home.packages = with pkgs.llm-agents; [
        agent-browser
        officecli
        pdfvision
      ];

      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;

        skills = {
          agent-browser = "${pkgs.llm-agents.agent-browser.src}/skills/agent-browser";
          git-signing = ../../skills/git-signing;
          officecli = "${pkgs.llm-agents.officecli.src}/skills/officecli";
          pdfvision = "${pkgs.llm-agents.pdfvision.src}/skills/pdfvision";
        };
      };
    };
}
