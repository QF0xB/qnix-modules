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

          workspace="$1"
          wanted="$2"
          shift 3

          exists="$(${pkgs.hyprland}/bin/hyprctl -j clients | ${pkgs.jq}/bin/jq -r --arg value "$wanted" '
            any(.[]; (.class == $value) or (.initialClass == $value))
          ')"

          if [ "$exists" != "true" ]; then
            uwsm app -- "$@" >/dev/null 2>&1 &
          fi

          ${pkgs.hyprland}/bin/hyprctl dispatch togglespecialworkspace "$workspace" >/dev/null
        '';
      };
    in
    {
      home.packages = [ hyprSpecial ];
    };
}
