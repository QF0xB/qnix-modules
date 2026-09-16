{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.hyprland" ];

  home =
    {
      pkgs,
      ...
    }:
    let
      hyprSpecial = pkgs.writeShellApplication {
        name = "hypr-special";
        runtimeInputs = [
          pkgs.hyprland
          pkgs.jq
        ];
        text = ''
          set -eu

          if [ "$#" -lt 4 ] || [ "$3" != "--" ]; then
            echo "usage: hypr-special <specialName> <matchValue> -- <command> [args...]" >&2
            exit 2
          fi

          ws="$1"
          want="$2"
          shift 3

          exists="$(
            hyprctl -j clients | jq -r --arg v "$want" '
              any(.[]; (.class == $v) or (.initialClass == $v))
            '
          )"

          if [ "$exists" != "true" ]; then
            uwsm app -- "$@" >/dev/null 2>&1 &
          else
            hyprctl dispatch togglespecialworkspace "$ws" >/dev/null
          fi
        '';
      };
    in
    {
      home.packages = [ hyprSpecial ];
    };
}
