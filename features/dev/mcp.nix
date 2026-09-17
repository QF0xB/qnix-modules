{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [
    "desktop.xdg-folders"
    "dev.git"
  ];

  home =
    {
      config,
      context,
      lib,
      pkgs,
      osConfig ? null,
      ...
    }:
    let
      mcpInput = lib.attrByPath [ "mcp-servers-nix" ] null context;
      mcpPkgs = if mcpInput == null then pkgs else pkgs.extend mcpInput.overlays.default;
      evaluated =
        if mcpInput == null then
          { config.settings.servers = { }; }
        else
          mcpInput.lib.evalModule mcpPkgs {
            flavor = "claude";

            programs = {
              filesystem = {
                enable = true;
                args = [ config.xdg.userDirs.projects ];
              };
              git.enable = true;
              github.enable = true;
            }
            // lib.optionalAttrs (osConfig != null) {
              nixos.enable = true;
            };
          };
      servers = evaluated.config.settings.servers or { };
      githubServer = servers.github or null;
      githubMcp = lib.optionalString (githubServer != null) (
        pkgs.writeShellScriptBin "qnix-github-mcp-server" ''
          if ! token="$(${config.programs.gh.package}/bin/gh auth token)"; then
            echo "qnix GitHub MCP: authenticate gh before starting OpenCode" >&2
            exit 1
          fi

          export GITHUB_PERSONAL_ACCESS_TOKEN="$token"
          exec ${lib.escapeShellArgs ([ githubServer.command ] ++ githubServer.args)}
        ''
      );
      codegraphMcp = pkgs.writeShellApplication {
        name = "qnix-codegraph-mcp";
        runtimeInputs = [
          pkgs.git
          pkgs.llm-agents.codegraph
        ];
        text = ''
          if project_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
            if [[ ! -d "$project_root/.codegraph" ]]; then
              codegraph init "$project_root" --yes >&2
            fi

            cd "$project_root"
          fi

          exec codegraph serve --mcp
        '';
      };
    in
    {
      programs.mcp.servers =
        servers
        // {
          codegraph = {
            command = "${codegraphMcp}/bin/qnix-codegraph-mcp";
          };
        }
        // lib.optionalAttrs (githubServer != null) {
          github = githubServer // {
            command = "${githubMcp}/bin/qnix-github-mcp-server";
            args = [ ];
          };
        };

      programs.mcp.enable = true;
    };
}
