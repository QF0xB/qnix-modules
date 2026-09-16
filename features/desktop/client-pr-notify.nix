{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  options = { lib, ... }: {
    owner = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    repo = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    sopsSecretName = lib.mkOption {
      type = lib.types.str;
      default = "github-token";
    };
    githubTokenPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    matchAuthors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    matchAnyLabel = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    titleContains = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    bootDelaySec = lib.mkOption {
      type = lib.types.ints.positive;
      default = 120;
    };
  };

  home =
    {
      cfg,
      config,
      lib,
      osConfig ? null,
      pkgs,
      ...
    }:
    let
      tokenPath =
        if cfg.githubTokenPath != null then
          cfg.githubTokenPath
        else if osConfig != null then
          lib.attrByPath [ "sops" "secrets" cfg.sopsSecretName "path" ] null osConfig
        else
          null;
      check = pkgs.writeShellApplication {
        name = "qnix-client-pr-notify";
        runtimeInputs = [
          pkgs.curl
          pkgs.jq
          pkgs.libnotify
        ];
        text = ''
          set -euo pipefail
          state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/qnix-client-pr-notify"
          state_file="$state_dir/last-max-pr-number"
          mkdir -p "$state_dir"
          last=0
          [ -f "$state_file" ] && last=$(tr -d '[:space:]' < "$state_file" || true)
          auth=()
          if [ -n "''${GITHUB_TOKEN_FILE:-}" ] && [ -f "''${GITHUB_TOKEN_FILE}" ]; then
            auth=(-H "Authorization: Bearer $(<"$GITHUB_TOKEN_FILE")" -H "Accept: application/vnd.github+json")
          fi
          url="https://api.github.com/repos/${cfg.owner}/${cfg.repo}/pulls?state=open&per_page=100"
          json=$(curl -sf "''${auth[@]}" "$url") || exit 0
          filtered=$(printf '%s' "$json" | jq \
            --argjson authors '${builtins.toJSON cfg.matchAuthors}' \
            --argjson labels '${builtins.toJSON cfg.matchAnyLabel}' \
            --arg title '${if cfg.titleContains == null then "" else cfg.titleContains}' \
            '[.[] | . as $pr | select(($authors | length) == 0 or any($authors[]; . == $pr.user.login)) | select(($labels | length) == 0 or any($pr.labels[]; .name as $label | any($labels[]; . == $label))) | select(($title | length) == 0 or ($pr.title | contains($title)))]')
          count=$(printf '%s' "$filtered" | jq 'length')
          [ "$count" -gt 0 ] || exit 0
          max_pr=$(printf '%s' "$filtered" | jq 'map(.number) | max')
          [ "$max_pr" -gt "$last" ] || exit 0
          summary=$(printf '%s' "$filtered" | jq -r 'if length == 1 then .[0] | "\(.title) (#\(.number))" else "\(length) matching PRs (highest #\(map(.number) | max))" end')
          notify-send --app-name="QNix" "Client repo: matching PR" "${cfg.owner}/${cfg.repo} - $summary"
          printf '%s\n' "$max_pr" > "$state_file"
        '';
      };
    in
    {
      assertions = [
        {
          assertion = !cfg.enable || (cfg.owner != "" && cfg.repo != "");
          message = "qnix.desktop.client-pr-notify: owner and repo must be set when enabled.";
        }
        {
          assertion =
            !cfg.enable || (cfg.matchAuthors != [ ] || cfg.matchAnyLabel != [ ] || cfg.titleContains != null);
          message = "qnix.desktop.client-pr-notify: set at least one matching filter when enabled.";
        }
        {
          assertion = !cfg.enable || tokenPath != null;
          message = "qnix.desktop.client-pr-notify: define a token path or an sops secret when enabled.";
        }
      ];

      systemd.user.services.qnix-client-pr-notify = lib.mkIf cfg.enable {
        Unit = {
          Description = "Notify about matching GitHub pull requests";
          Requires = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${check}/bin/qnix-client-pr-notify";
          Environment = [
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
          ]
          ++ (if tokenPath == null then [ ] else [ "GITHUB_TOKEN_FILE=${tokenPath}" ]);
        };
      };

      systemd.user.timers.qnix-client-pr-notify = lib.mkIf cfg.enable {
        Unit.Description = "Run the GitHub pull request notifier after login";
        Timer = {
          OnBootSec = "${toString cfg.bootDelaySec}s";
          Unit = "qnix-client-pr-notify.service";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
