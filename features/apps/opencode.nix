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

    };
}
