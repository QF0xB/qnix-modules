{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "dev.mcp" ];

  persistence.users."*".directories = [
    ".gemini"
    ".local/share/rtk"
  ];

  home =
    { lib, pkgs, ... }:
    let
      agentPlugins = pkgs.callPackage ../../packages/agent-plugins.nix { };
      jsonFormat = pkgs.formats.json { };
      pluginDir = ".gemini/config/plugins/qnix";
    in
    {
      # The rtk hook and the skills call their CLIs by name.
      home.packages = with pkgs.llm-agents; [
        pkgs.codex
        agent-browser
        officecli
        pdfvision
        rtk
        agentPlugins.aislop
      ];

      programs.git.ignores = agentPlugins.gitIgnores;

      programs.antigravity-cli = {
        enable = true;
        package = pkgs.llm-agents.antigravity-cli;
        enableMcpIntegration = true;

        skills = {
          agent-browser = "${pkgs.llm-agents.agent-browser.src}/skills/agent-browser";
          # Hands self-contained tasks to Codex on the ChatGPT subscription.
          codex-delegate = ../../skills/codex-delegate;
          git-signing = ../../skills/git-signing;
          officecli = "${pkgs.llm-agents.officecli.src}/skills/officecli";
          pdfvision = "${pkgs.llm-agents.pdfvision.src}/skills/pdfvision";
        }
        // agentPlugins.skills;
      };

      # Antigravity plugin in the layout `rtk init -g --agent antigravity`
      # writes: the rtk command rewrite hook plus always-on rules. aislop has
      # no Antigravity edit hook, so its rules ship through the same context.
      home.file = {
        "${pluginDir}/plugin.json".source = jsonFormat.generate "antigravity-qnix-plugin.json" {
          name = "qnix";
          version = "1.0.0";
          description = "QNix rules and rtk command rewriting";
        };
        "${pluginDir}/hooks.json".source = jsonFormat.generate "antigravity-qnix-hooks.json" {
          rtk-rewrite = {
            enabled = true;
            PreToolUse = [
              {
                matcher = "run_command";
                hooks = [
                  {
                    type = "command";
                    command = "${lib.getExe pkgs.llm-agents.rtk} hook antigravity";
                    timeout = 10;
                  }
                ];
              }
            ];
          };
        };
        "${pluginDir}/rules/AGENTS.md".text = agentPlugins.agentsContext;
      };
    };
}
