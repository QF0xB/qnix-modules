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
    { lib, pkgs, ... }:
    let
      gitAiOpenCodePlugin = pkgs.runCommand "qnix-git-ai-opencode-plugin" { } ''
        substitute \
          ${pkgs.llm-agents.git-ai.src}/agent-support/opencode/git-ai.ts \
          "$out" \
          --replace-fail \
          "__GIT_AI_BINARY_PATH__" \
          "${pkgs.llm-agents.git-ai}/bin/git-ai"
      '';
    in
    {
      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
        # Keeps RTK in OpenCode's PATH even when the developer profile is not selected.
        extraPackages = [ pkgs.llm-agents.rtk ];
        enableMcpIntegration = true;
      };

      # RTK owns and updates its OpenCode hook. This is equivalent to running
      # `rtk init -g --opencode --auto-patch` manually after each activation.
      home.activation.installRtkOpenCodeHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.llm-agents.rtk}/bin/rtk init -g --opencode --auto-patch
      '';

      # Use Git AI's maintained OpenCode plugin with the immutable Nix path
      # substituted in place of the path normally written by `install-hooks`.
      xdg.configFile."opencode/plugins/git-ai.ts".source = gitAiOpenCodePlugin;
    };
}
