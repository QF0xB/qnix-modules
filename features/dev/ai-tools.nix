{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [
    ".agentsview"
    ".ctx"
  ];

  home =
    { pkgs, ... }:
    let
      qnixDev = pkgs.writeShellApplication {
        name = "qnix-dev";
        runtimeInputs = [ pkgs.systemd ];
        text = ''
          case "''${1:-}" in
            start)
              ${pkgs.llm-agents.ctx}/bin/ctx setup --quiet --no-daemon
              systemctl --user start qnix-ctx.service qnix-agentsview.service
              ;;
            stop)
              systemctl --user stop qnix-ctx.service qnix-agentsview.service
              ;;
            restart)
              systemctl --user restart qnix-ctx.service qnix-agentsview.service
              ;;
            status)
              systemctl --user status qnix-ctx.service qnix-agentsview.service
              ;;
            *)
              echo "Usage: qnix-dev {start|stop|restart|status}" >&2
              exit 2
              ;;
          esac
        '';
      };
    in
    {
      home.packages =
        (with pkgs.llm-agents; [
          agent-browser
          agentsview
          ccusage
          codegraph
          ctx
          officecli
          pdfvision
          rtk
          skills
        ])
        ++ [ qnixDev ];

      systemd.user.services = {
        qnix-ctx = {
          Unit.Description = "QNix ctx indexer";
          Service = {
            ExecStart = "${pkgs.llm-agents.ctx}/bin/ctx daemon run";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        qnix-agentsview = {
          Unit.Description = "QNix AgentsView";
          Service = {
            ExecStart = "${pkgs.llm-agents.agentsview}/bin/agentsview serve";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
    };
}
