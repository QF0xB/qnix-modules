{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "dev.mcp" ];

  persistence.users."*".directories = [
    ".codex"
    ".config/opencode/skills"
    ".local/state/opencode"
    ".local/share/opencode"
    ".local/share/rtk"
  ];

  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      agentPlugins = pkgs.callPackage ../../packages/agent-plugins.nix { };

      # OpenCode and Codex both read plain skill directories and a global
      # AGENTS.md, so they share the same skills and always-on rules.
      skills = {
        agent-browser = "${pkgs.llm-agents.agent-browser.src}/skills/agent-browser";
        git-signing = ../../skills/git-signing;
        officecli = "${pkgs.llm-agents.officecli.src}/skills/officecli";
        pdfvision = "${pkgs.llm-agents.pdfvision.src}/skills/pdfvision";
      }
      // agentPlugins.skills;

      opencodeLauncher = pkgs.writeShellApplication {
        name = "opencode-launcher";
        runtimeInputs = [
          pkgs.fd
          pkgs.fzf
          pkgs.llm-agents.opencode
        ];
        text = ''
          set -eu

          project="$({
            printf '%s\n' "$HOME"
            fd --type directory --hidden \
              --exclude .cache \
              --exclude .config \
              --exclude .git \
              --exclude .local \
              --exclude .nix-profile \
              --exclude node_modules \
              . "$HOME"
          } | fzf --prompt="OpenCode folder> ")" || exit 0

          [ -n "$project" ] || exit 0
          exec opencode "$project"
        '';
      };
    in
    {
      home.packages = [
        pkgs.opencode-desktop
        pkgs.vscode
        pkgs.llm-agents.rtk
        agentPlugins.aislop
      ];

      programs.codex = {
        enable = true;
        package = pkgs.codex;
        context = agentPlugins.agentsContext;
        inherit skills;
        # Rewrites shell commands to their condensed `rtk` equivalents. Codex
        # asks to trust new hooks once; approve it with `/hooks`.
        hooks.PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "${lib.getExe pkgs.llm-agents.rtk} hook codex";
              }
            ];
          }
        ];
      };

      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
        # These skills invoke their matching CLIs, so they must be available to
        # OpenCode even when the developer profile is not selected.
        extraPackages =
          (with pkgs.llm-agents; [
            agent-browser
            officecli
            pdfvision
            rtk
          ])
          ++ [ agentPlugins.aislop ];
        enableMcpIntegration = true;
        # OpenCode sends every MCP tool definition with each request. These
        # servers duplicate built-in tools or `gh`, so they stay available but
        # off. Enable one in OpenCode when a session needs it.
        settings.mcp =
          lib.mapAttrs
            (_: server: {
              type = "local";
              command = [ server.command ] ++ server.args;
              enabled = false;
            })
            (
              lib.filterAttrs (
                name: _:
                lib.elem name [
                  "filesystem"
                  "git"
                  "github"
                ]
              ) config.programs.mcp.servers
            );
        context = agentPlugins.agentsContext;
        inherit skills;

        tui.plugin = [ "@satas/opencode-usage-bar@0.2.0" ];
      };

      xdg.configFile."opencode/usage-bar.toml".text = ''
        [anthropic]
        enabled = false

        [openai]
        enabled = true
        show_5h = true
        show_7d = true
      '';

      # opencode-usage-bar 0.2.0 reads OpenCode's auth store from the XDG
      # state directory, while OpenCode writes it under XDG data.
      xdg.stateFile."opencode/auth.json".source = config.lib.file.mkOutOfStoreSymlink (
        "${config.xdg.dataHome}/opencode/auth.json"
      );

      # The plugin `rtk init -g --opencode` installs, taken from the same rtk
      # release. Running `rtk init` during activation also patches the
      # read-only Claude Code settings since rtk 1.0 and fails activation.
      xdg.configFile."opencode/plugins/rtk.ts".source =
        "${pkgs.llm-agents.rtk.src}/hooks/opencode/rtk.ts";

      xdg.desktopEntries.opencode = {
        name = "OpenCode";
        genericName = "AI coding agent";
        comment = "Choose a folder and start OpenCode";
        exec = lib.getExe opencodeLauncher;
        icon = "utilities-terminal";
        terminal = true;
        categories = [
          "Development"
          "Utility"
        ];
      };
    };
}
