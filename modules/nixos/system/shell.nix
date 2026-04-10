{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.system.shell;
  qnixRoot = if cfg.projectRoot != null then builtins.dirOf cfg.projectRoot else null;
  qnixModulesGithubPrefix = "github:QF0xB/qnix-modules";
  qnixModulesFlakehubPrefix = "https://flakehub.com/f/QF0xB/qnix-modules";

  loginShellPackage =
    {
      fish = pkgs.fish;
      zsh = pkgs.zsh;
      bash = pkgs.bashInteractive;
    }
    .${cfg.defaultShell.package};

  loginShellBinary =
    "${loginShellPackage}/bin/${
      if cfg.defaultShell.package == "bash" then "bash" else cfg.defaultShell.package
    }";

  qnixReleaseHelper =
    if cfg.projectRoot != null then
      pkgs.writeText "qnix-release-helper.sh" ''
        set -euo pipefail

        CLIENT_ROOT=${lib.escapeShellArg cfg.projectRoot}
        QNIX_ROOT=${lib.escapeShellArg qnixRoot}
        MODULES_ROOT="$QNIX_ROOT/modules"
        CLIENT_FLAKE="$CLIENT_ROOT/flake.nix"
        MODULES_VERSION_FILE="$MODULES_ROOT/VERSION"
        GITHUB_RELEASE_PREFIX="''${QNIX_MODULES_GITHUB_PREFIX:-${qnixModulesGithubPrefix}}"
        FLAKEHUB_RELEASE_PREFIX="''${QNIX_MODULES_FLAKEHUB_PREFIX:-${qnixModulesFlakehubPrefix}}"

        die() {
          printf '%s\n' "$*" >&2
          exit 1
        }

        require_repo() {
          local repo="$1"
          git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not a git repository: $repo"
        }

        require_clean_repo() {
          local repo="$1"
          local label="$2"
          require_repo "$repo"
          if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
            die "$label repo is dirty: $repo"
          fi
        }

        ensure_client_input_is_managed() {
          grep -Fq '# Managed by qnix-dev-modules and qnix-use-release.' "$CLIENT_FLAKE" \
            || die "Missing managed qnix-modules marker in $CLIENT_FLAKE"
        }

        write_client_input_url() {
          local url="$1"

          ensure_client_input_is_managed

          perl -0pi -e 's@(?ms)(qnix-modules = \{\n\s*# Managed by qnix-dev-modules and qnix-use-release\.\n\s*url = ")[^"]+(";\n\s*\};)@$1'"$url"'$2@' "$CLIENT_FLAKE"
        }

        update_client_lock() {
          (
            cd "$CLIENT_ROOT"
            nix flake lock --update-input qnix-modules
          )
        }

        normalize_version() {
          local input="$1"

          [[ -n "$input" ]] || die "Missing version"

          if [[ "$input" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
            printf '%s\n' "''${BASH_REMATCH[1]}"
            return
          fi

          if [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            printf '%s\n' "$input"
            return
          fi

          die "Invalid version: $input"
        }

        normalize_source() {
          local input="$1"

          case "$input" in
            ""|github|flakehub)
              printf '%s\n' "''${input:-github}"
              ;;
            *)
              die "Unsupported source: $input"
              ;;
          esac
        }

        parse_release_args() {
          RELEASE_SOURCE="$(normalize_source "''${QNIX_MODULES_RELEASE_SOURCE:-github}")"
          RELEASE_ARG=""

          while [[ $# -gt 0 ]]; do
            case "$1" in
              --source)
                [[ $# -ge 2 ]] || die "Missing value for --source"
                RELEASE_SOURCE="$(normalize_source "$2")"
                shift 2
                ;;
              --source=*)
                RELEASE_SOURCE="$(normalize_source "''${1#--source=}")"
                shift
                ;;
              -*)
                die "Unknown option: $1"
                ;;
              *)
                [[ -z "$RELEASE_ARG" ]] || die "Unexpected extra argument: $1"
                RELEASE_ARG="$1"
                shift
                ;;
            esac
          done
        }

        release_url() {
          local source="$1"
          local version="$2"
          local ref="$3"

          case "$source" in
            github)
              printf '%s?ref=%s\n' "$GITHUB_RELEASE_PREFIX" "$ref"
              ;;
            flakehub)
              printf '%s/=%s\n' "$FLAKEHUB_RELEASE_PREFIX" "$version"
              ;;
            *)
              die "Unsupported source: $source"
              ;;
          esac
        }

        read_version() {
          if [[ -f "$MODULES_VERSION_FILE" ]]; then
            tr -d '[:space:]' < "$MODULES_VERSION_FILE"
          else
            printf '0.1.0\n'
          fi
        }

        bump_version() {
          local current="$1"
          local kind="$2"
          local major minor patch

          IFS=. read -r major minor patch <<<"$current"

          case "$kind" in
            major)
              major=$((major + 1))
              minor=0
              patch=0
              ;;
            minor)
              minor=$((minor + 1))
              patch=0
              ;;
            patch)
              patch=$((patch + 1))
              ;;
            *)
              die "Unsupported bump kind: $kind"
              ;;
          esac

          printf '%s.%s.%s\n' "$major" "$minor" "$patch"
        }
      ''
    else
      null;

  qnixReleaseTools = lib.optionalAttrs (cfg.projectRoot != null && cfg.qnixAliases) {
    qnix-dev-modules = {
      runtimeInputs = with pkgs; [
        git
        nix
        perl
      ];
      text = ''
        # shellcheck source=/dev/null
        source ${qnixReleaseHelper}

        require_repo "$CLIENT_ROOT"
        write_client_input_url "path:$MODULES_ROOT"
        update_client_lock

        printf 'Client now uses local qnix-modules at %s\n' "$MODULES_ROOT"
      '';
    };

    qnix-use-release = {
      runtimeInputs = with pkgs; [
        git
        nix
        perl
      ];
      text = ''
        # shellcheck source=/dev/null
        source ${qnixReleaseHelper}

        parse_release_args "$@"
        version="$(normalize_version "$RELEASE_ARG")"
        ref="v$version"
        url="$(release_url "$RELEASE_SOURCE" "$version" "$ref")"

        require_repo "$CLIENT_ROOT"
        write_client_input_url "$url"
        update_client_lock

        printf 'Client now uses qnix-modules %s via %s\n' "$ref" "$RELEASE_SOURCE"
      '';
    };

    qnix-sync-modules = {
      runtimeInputs = with pkgs; [
        git
        nix
      ];
      text = ''
        # shellcheck source=/dev/null
        source ${qnixReleaseHelper}

        require_repo "$CLIENT_ROOT"
        update_client_lock

        printf 'Updated client flake.lock for the current qnix-modules source\n'
      '';
    };

    qnix-release = {
      runtimeInputs = with pkgs; [
        git
        nix
        perl
      ];
      text = ''
        # shellcheck source=/dev/null
        source ${qnixReleaseHelper}

        parse_release_args "$@"
        bump="''${RELEASE_ARG:-patch}"
        current_version="$(read_version)"

        case "$bump" in
          major|minor|patch)
            version="$(bump_version "$current_version" "$bump")"
            ;;
          *)
            version="$(normalize_version "$bump")"
            ;;
        esac

        ref="v$version"

        require_clean_repo "$MODULES_ROOT" "modules"
        require_repo "$CLIENT_ROOT"

        if git -C "$MODULES_ROOT" rev-parse "$ref" >/dev/null 2>&1; then
          die "Git tag already exists: $ref"
        fi

        printf '%s\n' "$version" > "$MODULES_VERSION_FILE"
        git -C "$MODULES_ROOT" add VERSION
        git -C "$MODULES_ROOT" commit -m "release: $ref"
        git -C "$MODULES_ROOT" tag -a "$ref" -m "Release $ref"
        git -C "$MODULES_ROOT" push origin HEAD
        git -C "$MODULES_ROOT" push origin "$ref"

        write_client_input_url "$(release_url "$RELEASE_SOURCE" "$version" "$ref")"
        update_client_lock

        printf 'Released qnix-modules %s\n' "$ref"
        printf 'Client now points to %s via %s\n' "$ref" "$RELEASE_SOURCE"
        printf 'Review and commit %s/flake.nix and %s/flake.lock\n' "$CLIENT_ROOT" "$CLIENT_ROOT"
        printf 'GitHub Actions will publish tag %s as a GitHub Release.\n' "$ref"
      '';
    };
  };
in
{
  config = lib.mkIf cfg.enable {
    qnix.system.shell.packages = qnixReleaseTools;

    environment.systemPackages = lib.attrValues cfg.packages;

    qnix.persist.users."*".directories = lib.optionals (cfg.fish.enable || cfg.defaultShell.package == "fish") [
      ".local/share/fish"
    ];

    programs.bash.interactiveShellInit = lib.mkIf (cfg.defaultShell.enable && cfg.defaultShell.package != "bash") ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "${cfg.defaultShell.package}" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${loginShellBinary} $LOGIN_OPTION
      fi
    '';

    programs.fish.enable = cfg.fish.enable || cfg.defaultShell.package == "fish";

    programs.zsh = {
      enable = cfg.zsh.enable || cfg.defaultShell.package == "zsh";
      autosuggestions.enable = cfg.zsh.autosuggestions;
      syntaxHighlighting.enable = cfg.zsh.syntaxHighlighting;
      enableCompletion = cfg.zsh.enableCompletion;
    };

    users.defaultUserShell = lib.mkIf cfg.defaultShell.enable loginShellPackage;
  };
}
