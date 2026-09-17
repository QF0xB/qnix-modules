{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.wayland" ];

  options =
    { lib, ... }:
    {
      allowImages = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether ClipHist stores copied images in addition to text.";
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
      picker = pkgs.writeShellApplication {
        name = "qnix-clipboard-history";
        runtimeInputs = [
          pkgs.cliphist
          pkgs.fuzzel
          pkgs.wl-clipboard
        ];
        text = ''
          set -euo pipefail
          cliphist list | fuzzel --dmenu --prompt="Clipboard> " | cliphist decode | wl-copy
        '';
      };
    in
    {
      services.cliphist = {
        enable = cfg.enable;
        inherit (cfg) allowImages;
      };

      home.packages = lib.mkIf cfg.enable [ picker ];
      wayland.windowManager.hyprland.settings.bind = lib.mkIf cfg.enable [
        {
          _args = [
            "SUPER + V"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua { } (lib.getExe picker)})")
          ];
        }
      ];
    };
}
