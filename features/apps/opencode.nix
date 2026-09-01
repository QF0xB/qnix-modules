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
      fenceConfig = pkgs.writeText "qnix-opencode-fence.json" (
        builtins.toJSON {
          extends = "code";
          command.runtimeExecPolicy = "argv";
        }
      );
      fencedOpenCode = pkgs.writeShellApplication {
        name = "opencode";
        text = ''
          exec ${pkgs.llm-agents.fence}/bin/fence \
            --settings ${fenceConfig} \
            -- ${pkgs.llm-agents.opencode}/bin/opencode "$@"
        '';
      };
    in
    {
      programs.opencode = {
        enable = true;
        package = fencedOpenCode;
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

    };
}
