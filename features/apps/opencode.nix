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
      signedCommit = pkgs.writeShellApplication {
        name = "qnix-signed-commit";
        runtimeInputs = [
          pkgs.git
          pkgs.libnotify
        ];
        text = ''
          set -eu

          if [ "$#" -ne 1 ]; then
            echo "usage: qnix-signed-commit <message>" >&2
            exit 2
          fi

          if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo "qnix-signed-commit: not inside a Git repository" >&2
            exit 2
          fi

          if git diff --cached --quiet; then
            echo "qnix-signed-commit: no staged changes" >&2
            exit 2
          fi

          notify-send --urgency=critical --expire-time=0 \
            "YubiKey touch required" \
            "Touch your YubiKey to sign the final commit."

          if git commit -S -m "$1"; then
            notify-send "Signed commit created" "$1"
          else
            notify-send --urgency=critical --expire-time=0 \
              "Signed commit failed" \
              "Complete the YubiKey prompt and retry; staged changes were preserved."
            exit 1
          fi
        '';
      };
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
        extraPackages =
          (with pkgs.llm-agents; [
            agent-browser
            officecli
            pdfvision
            rtk
          ])
          ++ [ signedCommit ];
        enableMcpIntegration = true;

        tui.plugin = [ "@satas/opencode-usage-bar@0.2.0" ];

        skills = {
          agent-browser = "${pkgs.llm-agents.agent-browser.src}/skills/agent-browser";
          git-signing = ../../skills/git-signing;
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
