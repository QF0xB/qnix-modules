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
      config,
      lib,
      pkgs,
      ...
    }:
    let
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

        tui.plugin = [ "@satas/opencode-usage-bar@0.2.0" ];

        skills = {
          agent-browser = "${pkgs.llm-agents.agent-browser.src}/skills/agent-browser";
          officecli = "${pkgs.llm-agents.officecli.src}/skills/officecli";
          pdfvision = "${pkgs.llm-agents.pdfvision.src}/skills/pdfvision";
        };
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

      # RTK owns and updates its OpenCode hook. This is equivalent to running
      # `rtk init -g --opencode --auto-patch` manually after each activation.
      home.activation.installRtkOpenCodeHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.llm-agents.rtk}/bin/rtk init -g --opencode --auto-patch
      '';

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
