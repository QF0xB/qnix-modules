{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "dev.mcp" ];

  persistence.users."*" = {
    directories = [
      ".claude"
      ".local/share/rtk"
      ".plannotator"
    ];
    files = [ ".claude.json" ];
  };

  home =
    { lib, pkgs, ... }:
    let
      agentPlugins = pkgs.callPackage ../../packages/agent-plugins.nix { };
    in
    {
      # The rtk and plannotator hooks and the codex-delegate skill call their
      # CLIs by name.
      home.packages = with pkgs.llm-agents; [
        pkgs.codex
        agent-browser
        officecli
        pdfvision
        plannotator
        rtk
        agentPlugins.aislop
      ];

      programs.git.ignores = agentPlugins.gitIgnores;

      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;
        settings = {
          attribution = {
            commit = "";
            pr = "";
            sessionUrl = false;
          };

          # Shows the active caveman mode. Without it, the caveman session hook
          # asks Claude to set up the status line in every new install.
          statusLine = {
            type = "command";
            command = agentPlugins.claudeStatusLine;
          };

          hooks = {
            # Rewrites shell commands to their condensed `rtk` equivalents.
            PreToolUse = [
              {
                matcher = "Bash";
                hooks = [
                  {
                    type = "command";
                    command = "${lib.getExe pkgs.llm-agents.rtk} hook claude";
                  }
                ];
              }
            ];
            PostToolUse = [
              {
                matcher = "Edit|Write|MultiEdit";
                hooks = [
                  {
                    type = "command";
                    command = "${agentPlugins.aislopClaudeHook}";
                  }
                ];
              }
            ];
            # Refreshes the aislop score baseline when project rules change.
            FileChanged = [
              {
                matcher = ".aislop/config.yml|.aislop/rules.yml|package.json";
                hooks = [
                  {
                    type = "command";
                    command = agentPlugins.aislopClaudeFileChangedHook;
                  }
                ];
              }
            ];
          };
        };

        plugins = agentPlugins.claudePlugins;

        rules = {
          aislop = agentPlugins.aislopClaudeRule;
          rtk = agentPlugins.rtkRule;
        };

        skills = {
          agent-browser = "${pkgs.llm-agents.agent-browser.src}/skills/agent-browser";
          # Hands self-contained tasks to Codex on the ChatGPT subscription.
          codex-delegate = ../../skills/codex-delegate;
          git-signing = ../../skills/git-signing;
          officecli = "${pkgs.llm-agents.officecli.src}/skills/officecli";
          pdfvision = "${pkgs.llm-agents.pdfvision.src}/skills/pdfvision";
        };
      };
    };
}
