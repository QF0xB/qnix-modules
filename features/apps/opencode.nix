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
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
        # These skills invoke their matching CLIs, so they must be available to
        # OpenCode even when the developer profile is not selected.
        extraPackages = with pkgs.llm-agents; [
          agent-browser
          officecli
          pdfvision
          rtk
        ];
        enableMcpIntegration = true;

        skills = {
          agent-browser = "${pkgs.llm-agents.agent-browser.src}/skills/agent-browser";
          officecli = "${pkgs.llm-agents.officecli.src}/skills/officecli";
          pdfvision = "${pkgs.llm-agents.pdfvision.src}/skills/pdfvision";
        };
      };

      # RTK owns and updates its OpenCode hook. This is equivalent to running
      # `rtk init -g --opencode --auto-patch` manually after each activation.
      home.activation.installRtkOpenCodeHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.llm-agents.rtk}/bin/rtk init -g --opencode --auto-patch
      '';

      xdg.desktopEntries.opencode = {
        name = "OpenCode";
        genericName = "AI coding agent";
        comment = "OpenCode terminal interface";
        exec = "${lib.getExe pkgs.llm-agents.opencode}";
        icon = "utilities-terminal";
        terminal = true;
        categories = [
          "Development"
          "Utility"
        ];
      };
    };
}
