{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  pkgs,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg =
    if lib.hasAttrByPath [ "desktop" "clientPrNotify" ] qconfig then
      qconfig.desktop.clientPrNotify
    else
      {
        enable = false;
        owner = "";
        repo = "";
        sopsSecretName = "github-token";
        githubTokenPath = null;
        matchAuthors = [ ];
        matchAnyLabel = [ ];
        titleContains = null;
        bootDelaySec = 120;
      };

  secretName = cfg.sopsSecretName;

  tokenPath =
    if cfg.githubTokenPath != null then
      cfg.githubTokenPath
    else if osConfig != null && lib.hasAttrByPath [ "sops" "secrets" ] osConfig && lib.hasAttr secretName osConfig.sops.secrets then
      osConfig.sops.secrets.${secretName}.path
    else
      null;

  ownersJson = builtins.toJSON cfg.matchAuthors;
  labelsJson = builtins.toJSON cfg.matchAnyLabel;
  titleSub = cfg.titleContains or "";

  checkScript = pkgs.writeShellApplication {
    name = "qnix-client-pr-notify";
    runtimeInputs = with pkgs; [
      curl
      jq
      libnotify
    ];
    text = ''
      set -euo pipefail

      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/qnix-client-pr-notify"
      state_file="$state_dir/last-max-pr-number"
      mkdir -p "$state_dir"

      last=0
      if [[ -f "$state_file" ]]; then
        last=$(tr -d '[:space:]' < "$state_file" || echo 0)
      fi

      auth=()
      if [[ -n "''${GITHUB_TOKEN_FILE:-}" && -f "''${GITHUB_TOKEN_FILE}" ]]; then
        token=$(<"''${GITHUB_TOKEN_FILE}")
        auth=(-H "Authorization: Bearer $token" -H "Accept: application/vnd.github+json")
      fi

      url="https://api.github.com/repos/${cfg.owner}/${cfg.repo}/pulls?state=open&per_page=100"
      if ! json=$(curl -sf "''${auth[@]}" "$url"); then
        echo "qnix-client-pr-notify: failed to fetch $url" >&2
        exit 0
      fi

      filtered=$(
        echo "$json" | ${lib.getExe pkgs.jq} \
          --argjson authors '${ownersJson}' \
          --argjson labels '${labelsJson}' \
          --arg titlesub '${titleSub}' \
          '
          def label_ok:
            if ($labels | length) == 0 then true
            else (.labels | map(.name) | any(. as $n | $labels | index($n) != null))
            end;
          def author_ok:
            if ($authors | length) == 0 then true
            else (.user.login as $u | $authors | index($u) != null)
            end;
          def title_ok:
            if ($titlesub | length) == 0 then true
            else (.title | contains($titlesub))
            end;

          [ .[] | select(label_ok and author_ok and title_ok) ]
          '
      )

      count=$(echo "$filtered" | ${lib.getExe pkgs.jq} 'length')
      if [[ "$count" -eq 0 ]]; then
        exit 0
      fi

      max_pr=$(echo "$filtered" | ${lib.getExe pkgs.jq} 'map(.number) | max')
      if [[ "$max_pr" -le "$last" ]]; then
        exit 0
      fi

      summary=$(
        echo "$filtered" | ${lib.getExe pkgs.jq} -r '
          if length == 1 then
            .[0] | "\(.title) (#\(.number))"
          else
            "\(length) matching PRs (highest #\(map(.number) | max))"
          end
        '
      )
      body="${cfg.owner}/${cfg.repo} — $summary"

      "${pkgs.libnotify}/bin/notify-send" \
        -a "QNix" \
        "Client repo: cached update available" \
        "$body"

      echo "$max_pr" > "$state_file"
    '';
  };

  tokenEnv = lib.optionalAttrs (tokenPath != null) {
    GITHUB_TOKEN_FILE = tokenPath;
  };
in
{
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion =
            !cfg.enable || (cfg.matchAuthors != [ ] || cfg.matchAnyLabel != [ ] || cfg.titleContains != null);
          message = "qnix.desktop.clientPrNotify: set at least one of matchAuthors, matchAnyLabel, or titleContains.";
        }
        {
          assertion = !cfg.enable || tokenPath != null;
          message = "qnix.desktop.clientPrNotify: define sops.secrets.${secretName} on NixOS (sops-nix), or set githubTokenPath to a token file.";
        }
      ];
    }

    (lib.mkIf cfg.enable {
      systemd.user.services.qnix-client-pr-notify = {
        Unit = {
          Description = "Notify about matching GitHub PRs on the QNix client repo";
          After = [ "graphical-session.target" ];
        };

        Service = {
          Type = "oneshot";
          Environment = lib.mapAttrsToList (n: v: "${n}=${v}") tokenEnv;
          ExecStart = "${checkScript}/bin/qnix-client-pr-notify";
        };
      };

      systemd.user.timers.qnix-client-pr-notify = {
        Unit = {
          Description = "Run QNix client-repo PR check after session start";
        };

        Timer = {
          OnBootSec = "${toString cfg.bootDelaySec}s";
          Unit = "qnix-client-pr-notify.service";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    })
  ];
}
