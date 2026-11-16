{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  options =
    { lib, ... }:
    {
      host = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "ios-builder";
        description = "SSH host of the macOS machine that builds iOS apps.";
      };

      remoteRoot = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "build";
        description = "Directory on the build host, relative to its home, that holds one checkout per project.";
      };

      targetFramework = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "net10.0-ios";
        description = "Default .NET target framework for iOS builds.";
      };

      runtimeIdentifier = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "ios-arm64";
        description = "Default .NET runtime identifier for iOS builds.";
      };
    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    let
      iosRemoteBuild = pkgs.writeShellApplication {
        name = "ios-remote-build";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.git
          pkgs.gnugrep
          pkgs.openssh
          pkgs.rsync
        ];
        # Remote commands are assembled locally from %q-quoted values on purpose.
        excludeShellChecks = [ "SC2029" ];
        text = ''
          host=${lib.escapeShellArg cfg.host}
          remote_root=${lib.escapeShellArg cfg.remoteRoot}
          default_tfm=${lib.escapeShellArg cfg.targetFramework}
          tfm=""
          rid=${lib.escapeShellArg cfg.runtimeIdentifier}
          configuration=Release
          project=""
          output=""
          extra_args=()

          usage() {
            cat <<EOF
          Usage: ios-remote-build [options] [-- extra dotnet publish arguments]

          Sync the current project to a macOS host, publish an iOS .ipa there,
          and copy the result back.

            -p, --project PATH     iOS .csproj (default: the only iOS project found)
            -H, --host HOST        SSH host (default: $host)
            -f, --framework TFM    Target framework (default: the project's iOS one, else $default_tfm)
            -r, --runtime RID      Runtime identifier (default: $rid)
            -c, --configuration C  Build configuration (default: $configuration)
            -o, --output DIR       Local artifact directory (default: <root>/artifacts/ios)
            -h, --help             Show this help
          EOF
          }

          while (($# > 0)); do
            case "$1" in
              -p | --project) project="$2"; shift 2 ;;
              -H | --host) host="$2"; shift 2 ;;
              -f | --framework) tfm="$2"; shift 2 ;;
              -r | --runtime) rid="$2"; shift 2 ;;
              -c | --configuration) configuration="$2"; shift 2 ;;
              -o | --output) output="$2"; shift 2 ;;
              -h | --help) usage; exit 0 ;;
              --) shift; extra_args=("$@"); break ;;
              *) echo "ios-remote-build: unknown argument: $1" >&2; usage >&2; exit 2 ;;
            esac
          done

          root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
          name=$(basename "$root")
          remote_dir="$remote_root/$name"
          output=''${output:-$root/artifacts/ios}

          if [[ -z "$project" ]]; then
            mapfile -t candidates < <(
              find "$root" -name '*.csproj' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/node_modules/*' -print0 \
                | xargs -0 -r grep -l -E '<TargetFrameworks?[^>]*>[^<]*-ios' \
                | sort
            )
            if ((''${#candidates[@]} != 1)); then
              echo "ios-remote-build: found ''${#candidates[@]} iOS projects; pass one with --project:" >&2
              printf '  %s\n' "''${candidates[@]}" >&2
              exit 1
            fi
            project=''${candidates[0]}
          fi
          project=$(realpath --relative-to="$root" "$project")

          if [[ -z "$tfm" ]]; then
            mapfile -t frameworks < <(grep -oE 'net[0-9]+\.[0-9]+-ios[0-9.]*' "$root/$project" | sort -u)
            if ((''${#frameworks[@]} == 1)); then
              tfm=''${frameworks[0]}
            else
              tfm=$default_tfm
            fi
          fi

          echo "Syncing $root to $host:$remote_dir"
          ssh "$host" "mkdir -p $(printf '%q' "$remote_dir")"
          rsync -az --delete \
            --exclude .git \
            --exclude bin \
            --exclude obj \
            --exclude .idea \
            --exclude .vs \
            --exclude artifacts \
            --exclude node_modules \
            "$root/" "$host:$remote_dir/"

          # Pick up only the packages this build writes, not stale ones in bin/.
          marker=".ios-remote-build-started"
          publish=(
            dotnet publish "$project"
            -f "$tfm"
            -c "$configuration"
            "-p:RuntimeIdentifier=$rid"
            -p:ArchiveOnBuild=true
            "''${extra_args[@]}"
          )
          echo "Publishing $project ($tfm, $rid, $configuration) on $host"
          # A login shell, because macOS only puts dotnet on PATH via /etc/zprofile.
          build="cd $(printf '%q' "$remote_dir") && touch $marker && $(printf '%q ' "''${publish[@]}")"
          ssh "$host" "\"\$SHELL\" -lc $(printf '%q' "$build")"

          mapfile -t packages < <(
            ssh "$host" "cd $(printf '%q' "$remote_dir") && find . -name '*.ipa' -newer $marker -not -path './.git/*'"
          )
          if ((''${#packages[@]} == 0)); then
            echo "ios-remote-build: the build produced no .ipa" >&2
            exit 1
          fi

          mkdir -p "$output"
          for package in "''${packages[@]}"; do
            rsync -az "$host:$remote_dir/''${package#./}" "$output/"
            echo "Fetched $output/$(basename "$package")"
          done
        '';
      };
    in
    {
      home.packages = [ iosRemoteBuild ];
    };
}
