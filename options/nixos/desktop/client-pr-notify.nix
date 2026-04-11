{
  lib,
  ...
}:
{
  options.qnix.desktop.clientPrNotify = {
    enable = lib.mkEnableOption ''
      After graphical session starts, check the configured GitHub repo for open pull
      requests matching your filters (for example Garnix cache update PRs) and show a
      desktop notification when there is something new since the last run.
    '';

    owner = lib.mkOption {
      type = lib.types.str;
      example = "QF0xB";
      description = "GitHub organization or user that owns the client repository.";
    };

    repo = lib.mkOption {
      type = lib.types.str;
      example = "qnix-client";
      description = "GitHub repository name (the client flake repo).";
    };

    sopsSecretName = lib.mkOption {
      type = lib.types.str;
      default = "github-token";
      description = ''
        Name of the secret under NixOS `sops.secrets.<name>` (sops-nix). The file at
        `config.sops.secrets.<name>.path` is passed to the checker as `GITHUB_TOKEN_FILE`.
        Ensure the secret is readable by your login user (set `owner` / `group` / `mode`
        on `sops.secrets.<name>` as needed for user systemd units).
      '';
    };

    githubTokenPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/run/agenix/github-token";
      description = ''
        If set, use this path instead of the sops secret path for `sopsSecretName`. Use when
        not on NixOS with sops-nix, or to override the default.
      '';
    };

    matchAuthors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "github-actions[bot]" ];
      description = ''
        If non-empty, only pull requests whose author login is in this list are considered.
      '';
    };

    matchAnyLabel = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "automated" ];
      description = ''
        If non-empty, the pull request must have at least one of these label names.
      '';
    };

    titleContains = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "flake.lock";
      description = ''
        If set, the pull request title must contain this substring (case-sensitive).
      '';
    };

    bootDelaySec = lib.mkOption {
      type = lib.types.int;
      default = 120;
      description = ''
        Wait this many seconds after the graphical session unit starts before the first
        check (gives the network and notification daemon time to come up).
      '';
    };
  };
}
