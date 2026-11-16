{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  options =
    { lib, ... }:
    {
      workflow = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "ios-adhoc.yml";
        description = "GitHub Actions workflow whose artifacts hold the installable .ipa.";
      };
    };

  # libimobiledevice talks to devices through usbmuxd.
  nixos = {
    services.usbmuxd.enable = true;
  };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    let
      iosInstall = pkgs.writeShellApplication {
        name = "ios-install";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.gh
          pkgs.git
          pkgs.ideviceinstaller
          pkgs.libimobiledevice
        ];
        text = ''
          workflow=${lib.escapeShellArg cfg.workflow}
          repo=""
          branch=""
          run_id=""
          build=false
          ipa=""

          usage() {
            cat <<EOF
          Usage: ios-install [options] [FILE.ipa]

          Install an .ipa on the iPhone connected over USB. Without FILE, download
          the newest successful run of a GitHub Actions workflow for the current
          branch and install the .ipa from its artifacts.

            -b, --branch BRANCH    Branch to take the build from (default: current)
            -r, --run ID           Use this workflow run instead of the newest
            -R, --repo OWNER/REPO  Repository (default: the current checkout's)
            -w, --workflow FILE    Workflow (default: $workflow)
                --build            Start a new run on the branch and wait for it
            -h, --help             Show this help
          EOF
          }

          die() {
            echo "ios-install: $*" >&2
            exit 1
          }

          while (($# > 0)); do
            case "$1" in
              -b | --branch) branch="$2"; shift 2 ;;
              -r | --run) run_id="$2"; shift 2 ;;
              -R | --repo) repo="$2"; shift 2 ;;
              -w | --workflow) workflow="$2"; shift 2 ;;
              --build) build=true; shift ;;
              -h | --help) usage; exit 0 ;;
              -*) echo "ios-install: unknown argument: $1" >&2; usage >&2; exit 2 ;;
              *) ipa="$1"; shift ;;
            esac
          done

          # Check the device first so a missing cable fails before a long download.
          mapfile -t devices < <(idevice_id -l)
          case ''${#devices[@]} in
            0) die "no iOS device found; connect it over USB and unlock it" ;;
            1) ;;
            *) die "more than one iOS device connected: ''${devices[*]}" ;;
          esac
          if ! idevicepair validate >/dev/null 2>&1; then
            echo "Pairing with the device; confirm \"Trust This Computer\" on it."
            idevicepair pair || die "pairing failed; unlock the device, tap Trust, and retry"
          fi

          if [[ -z "$ipa" ]]; then
            [[ -n "$repo" ]] || repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
            [[ -n "$branch" ]] || branch=$(git branch --show-current)
            [[ -n "$branch" ]] || die "not on a branch; pass --branch"

            if [[ "$build" == true ]]; then
              started=$(date -u +%Y-%m-%dT%H:%M:%SZ)
              echo "Starting $workflow on $repo@$branch"
              gh workflow run "$workflow" -R "$repo" --ref "$branch"
              for _ in $(seq 30); do
                run_id=$(gh run list -R "$repo" -w "$workflow" -b "$branch" -e workflow_dispatch -L 1 \
                  --json databaseId,createdAt -q ".[] | select(.createdAt >= \"$started\") | .databaseId")
                [[ -n "$run_id" ]] && break
                sleep 2
              done
              [[ -n "$run_id" ]] || die "the new run did not show up"
              gh run watch "$run_id" -R "$repo" --exit-status || die "run $run_id failed"
            elif [[ -z "$run_id" ]]; then
              run_id=$(gh run list -R "$repo" -w "$workflow" -b "$branch" -s success -L 1 \
                --json databaseId -q '.[0].databaseId')
              [[ -n "$run_id" ]] || die "no successful $workflow run on $branch; try --build"
            fi

            download=$(mktemp -d)
            trap 'rm -rf "$download"' EXIT
            echo "Downloading artifacts of run $run_id"
            gh run download "$run_id" -R "$repo" -D "$download"
            mapfile -t packages < <(find "$download" -name '*.ipa')
            ((''${#packages[@]} == 1)) || die "run $run_id has ''${#packages[@]} .ipa files, expected one"
            ipa=''${packages[0]}
          fi

          [[ -f "$ipa" ]] || die "no such file: $ipa"
          echo "Installing $(basename "$ipa") on $(ideviceinfo -k DeviceName)"
          ideviceinstaller install "$ipa"
        '';
      };
    in
    {
      home.packages = [ iosInstall ];
    };
}
