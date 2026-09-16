{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      qnixRoot = "${config.home.homeDirectory}/Projects/qnix";
      helper = pkgs.writeText "qnix-release-helper.sh" ''
        set -euo pipefail

        QNIX_ROOT=${lib.escapeShellArg qnixRoot}
        CLIENT_ROOT="$QNIX_ROOT/client"
        MODULES_ROOT="$QNIX_ROOT/modules"
        CLIENT_FLAKE="$CLIENT_ROOT/flake.nix"
        MODULES_VERSION_FILE="$MODULES_ROOT/VERSION"
        GITHUB_RELEASE_PREFIX="''${QNIX_MODULES_GITHUB_PREFIX:-github:QF0xB/qnix-modules}"
        FLAKEHUB_RELEASE_PREFIX="''${QNIX_MODULES_FLAKEHUB_PREFIX:-https://flakehub.com/f/QF0xB/qnix-modules}"

        die() {
          printf '%s\n' "$*" >&2
          exit 1
        }

        require_repo() {
          local repo="$1"
          git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
            || die "Not a git repository: $repo"
        }

        require_clean_repo() {
          local repo="$1"
          local label="$2"
          require_repo "$repo"
          [[ -z "$(git -C "$repo" status --porcelain)" ]] \
            || die "$label repo is dirty: $repo"
        }

        ensure_client_input_is_managed() {
          grep -Fq '# Managed by qnix-dev-modules and qnix-use-release.' "$CLIENT_FLAKE" \
            || die "Missing managed qnix-modules marker in $CLIENT_FLAKE"
        }

        write_client_input_url() {
          local url="$1"
          ensure_client_input_is_managed
          perl -0pi -e 's@(?ms)(qnix-modules = \{\n\s*# Managed by qnix-dev-modules and qnix-use-release\.\n\s*url = ")[^"]+(";\n\s*inputs\.qnix-sdk\.follows = "qnix-sdk";\n\s*\};)@$1'"$url"'$2@' "$CLIENT_FLAKE"
        }

        update_client_lock() {
          (cd "$CLIENT_ROOT" && nix flake update qnix-modules)
        }

        normalize_version() {
          local input="$1"
          [[ -n "$input" ]] || die "Missing version"
          if [[ "$input" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
            printf '%s\n' "''${BASH_REMATCH[1]}"
          elif [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            printf '%s\n' "$input"
          else
            die "Invalid version: $input"
          fi
        }

        normalize_source() {
          case "$1" in
            ""|github|flakehub) printf '%s\n' "''${1:-flakehub}" ;;
            *) die "Unsupported source: $1" ;;
          esac
        }

        parse_release_args() {
          RELEASE_SOURCE="$(normalize_source "''${QNIX_MODULES_RELEASE_SOURCE:-flakehub}")"
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
              -*) die "Unknown option: $1" ;;
              *)
                [[ -z "$RELEASE_ARG" ]] || die "Unexpected extra argument: $1"
                RELEASE_ARG="$1"
                shift
                ;;
            esac
          done
        }

        release_url() {
          case "$1" in
            github) printf '%s?ref=%s\n' "$GITHUB_RELEASE_PREFIX" "$3" ;;
            flakehub) printf '%s/=%s\n' "$FLAKEHUB_RELEASE_PREFIX" "$2" ;;
            *) die "Unsupported source: $1" ;;
          esac
        }

        read_version() {
          [[ -f "$MODULES_VERSION_FILE" ]] && tr -d '[:space:]' < "$MODULES_VERSION_FILE" \
            || printf '0.1.0\n'
        }

        bump_version() {
          local major minor patch
          IFS=. read -r major minor patch <<<"$1"
          case "$2" in
            major) major=$((major + 1)); minor=0; patch=0 ;;
            minor) minor=$((minor + 1)); patch=0 ;;
            patch) patch=$((patch + 1)) ;;
            *) die "Unsupported bump kind: $2" ;;
          esac
          printf '%s.%s.%s\n' "$major" "$minor" "$patch"
        }
      '';

      runtimeInputs = with pkgs; [
        git
        nix
        perl
      ];

      mkTool =
        name: text:
        pkgs.writeShellApplication {
          inherit name runtimeInputs text;
        };

      qnixDevModules = mkTool "qnix-dev-modules" ''
        # shellcheck source=/dev/null
        source ${helper}
        require_repo "$CLIENT_ROOT"
        write_client_input_url "path:$MODULES_ROOT"
        update_client_lock
        printf 'Client now uses local qnix-modules at %s\n' "$MODULES_ROOT"
      '';

      qnixUseRelease = mkTool "qnix-use-release" ''
        # shellcheck source=/dev/null
        source ${helper}
        parse_release_args "$@"
        version="$(normalize_version "$RELEASE_ARG")"
        ref="v$version"
        require_repo "$CLIENT_ROOT"
        write_client_input_url "$(release_url "$RELEASE_SOURCE" "$version" "$ref")"
        update_client_lock
        printf 'Client now uses qnix-modules %s via %s\n' "$ref" "$RELEASE_SOURCE"
      '';

      qnixSyncModules = mkTool "qnix-sync-modules" ''
        # shellcheck source=/dev/null
        source ${helper}
        require_repo "$CLIENT_ROOT"
        update_client_lock
        printf 'Updated client flake.lock for the current qnix-modules source\n'
      '';

      qnixRelease = mkTool "qnix-release" ''
        # shellcheck source=/dev/null
        source ${helper}
        parse_release_args "$@"
        bump="''${RELEASE_ARG:-patch}"
        current_version="$(read_version)"
        case "$bump" in
          major|minor|patch) version="$(bump_version "$current_version" "$bump")" ;;
          *) version="$(normalize_version "$bump")" ;;
        esac
        ref="v$version"

        require_clean_repo "$MODULES_ROOT" "modules"
        require_repo "$CLIENT_ROOT"
        git -C "$MODULES_ROOT" rev-parse "$ref" >/dev/null 2>&1 \
          && die "Git tag already exists: $ref"

        printf '%s\n' "$version" > "$MODULES_VERSION_FILE"
        git -C "$MODULES_ROOT" add VERSION
        git -C "$MODULES_ROOT" commit -m "release: $ref"
        git -C "$MODULES_ROOT" tag -a "$ref" -m "Release $ref"
        git -C "$MODULES_ROOT" push origin HEAD
        git -C "$MODULES_ROOT" push origin "$ref"

        write_client_input_url "$(release_url "$RELEASE_SOURCE" "$version" "$ref")"
        if [[ "$RELEASE_SOURCE" == "flakehub" ]]; then
          printf 'Skipped flake lock: FlakeHub does not have %s until CI finishes.\n' "$ref"
          printf 'When the publish job is green, run: (cd %s && nix flake update qnix-modules)\n' "$CLIENT_ROOT"
        else
          update_client_lock
        fi

        printf 'Released qnix-modules %s\n' "$ref"
        printf 'Client now points to %s via %s\n' "$ref" "$RELEASE_SOURCE"
        printf 'CI will publish %s to FlakeHub and create the GitHub Release.\n' "$ref"
      '';
    in
    {
      home.packages = [
        qnixDevModules
        qnixUseRelease
        qnixSyncModules
        qnixRelease
      ];
    };
}
