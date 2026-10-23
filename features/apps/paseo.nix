{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  # Paseo plugins such as progress install launchers into ~/.local/bin and
  # link skills into ~/.agents/skills for agents.
  persistence.users."*".directories = [
    ".agents/skills"
    ".config/Paseo"
    ".local/bin"
    ".local/state/paseo-progress"
    ".paseo"
  ];

  options =
    { lib, ... }:
    {
      user = lib.mkOption {
        type = lib.types.str;
        default = "paseo";
        description = "User account under which the Paseo daemon runs.";
      };

      plugins = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          annotations = "neunzig-zehn/annotations";
          beautiful-chat = "aborakati/beautiful-chat";
          keep-awake = "hichamboushaba/keep-awake";
          mermaid = "dutchakdev/mermaid";
          paseo-cafe = "paseo-cafe/cafe";
          paseo-continuity = "keefeere/continuity";
          paseo-defer = "tomgrin10/defer";
          paseo-sidechat = "moyf/sidechat";
          progress = "stevecastaneda/progress";
          skills = "gpambrozio/skills";
          token-ledger = "stv1024/token-ledger";
          usage-auto-resume = "babo-jeonguk/usage-auto-resume";
          usage-monitor = "aborakati/usage-monitor";
        };
        description = ''
          Plugins installed through Paseo when they are missing, keyed by
          plugin ID with the registry source as value. Paseo owns installed
          plugins: updates, toggles, and removals made in the app are kept.
        '';
      };
    };

  nixos =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    let
      systemUser = cfg.user == "paseo";
      dataDir = if systemUser then "/var/lib/paseo" else "/home/${cfg.user}/.paseo";
      group = "paseo";
    in
    {
      users.users.paseo = lib.mkIf systemUser {
        isSystemUser = true;
        inherit group;
        home = dataDir;
      };
      users.groups.${group} = { };

      systemd.tmpfiles.rules = [ "d ${dataDir} 0700 ${cfg.user} ${group} - -" ];

      environment.systemPackages = [ pkgs.paseo ];

      systemd.services.paseo = {
        description = "Paseo daemon for AI coding agents";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        environment = {
          PASEO_HOME = dataDir;
          PASEO_LISTEN = "127.0.0.1:6767";
        }
        // lib.optionalAttrs (!systemUser) {
          # Agents started by the daemon need the user's tools, including
          # launchers that plugins install into ~/.local/bin.
          PATH = lib.mkForce (
            lib.concatStringsSep ":" [
              "/home/${cfg.user}/.local/bin"
              "/home/${cfg.user}/.nix-profile/bin"
              "/home/${cfg.user}/.local/state/nix/profile/bin"
              "/etc/profiles/per-user/${cfg.user}/bin"
              "/run/current-system/sw/bin"
              "/run/wrappers/bin"
              "/nix/var/nix/profiles/default/bin"
            ]
          );
        };
        serviceConfig = {
          User = cfg.user;
          Group = group;
          ExecStart = lib.getExe' pkgs.paseo "paseo-server";
          Restart = "on-failure";
          RestartSec = 5;
          TimeoutStopSec = 15;
        };
      };

      # Installs configured plugins that the daemon does not know yet. It never
      # reinstalls or updates, so a plugin removed in the app comes back only
      # after the next daemon start.
      systemd.services.paseo-plugins = lib.mkIf (cfg.plugins != { }) {
        description = "Install missing Paseo plugins";
        after = [
          "paseo.service"
          "network-online.target"
        ];
        wants = [ "network-online.target" ];
        requires = [ "paseo.service" ];
        wantedBy = [ "paseo.service" ];
        path = [
          pkgs.paseo
          pkgs.jq
        ];
        environment.PASEO_HOME = dataDir;
        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = group;
        };
        script = ''
          for attempt in $(seq 30); do
            installed="$(paseo plugin ls --json 2>/dev/null)" && break
            [ "$attempt" -lt 30 ] || { echo "Paseo daemon is not reachable" >&2; exit 1; }
            sleep 2
          done

          status=0
          ${lib.concatMapAttrsStringSep "\n" (id: source: ''
            if ! jq -e --arg id ${lib.escapeShellArg id} 'any(.[]; .id == $id)' <<<"$installed" >/dev/null; then
              echo "Installing Paseo plugin ${id} from ${source}"
              paseo plugin install ${lib.escapeShellArg source} --id ${lib.escapeShellArg id} </dev/null || status=1
            fi
          '') cfg.plugins}
          exit "$status"
        '';
      };
    };

  home =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.paseo
        pkgs.paseo-desktop
        pkgs.nodejs_22
      ];
    };
}
