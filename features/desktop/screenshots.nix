{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [
    "desktop.hyprland"
    "desktop.xdg-folders"
  ];

  options =
    { config, lib, ... }:
    {
      outputDirectory = lib.mkOption {
        type = lib.types.str;
        default = "${config.xdg.userDirs.pictures}/Screenshots";
        description = "Directory in which screenshots are saved.";
      };

      copyToClipboard = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether captured screenshots are copied to the clipboard.";
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
      mkScreenshot =
        name: capture:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [
            pkgs.coreutils
            pkgs.grim
            pkgs.slurp
            pkgs.wl-clipboard
          ];
          text = ''
            directory=${lib.escapeShellArg cfg.outputDirectory}
            filename="$directory/$(date +%Y-%m-%d_%H-%M-%S).png"

            mkdir -p "$directory"
            ${capture} "$filename"
            ${lib.optionalString cfg.copyToClipboard "wl-copy --type image/png < \"$filename\""}
          '';
        };
      region = mkScreenshot "qnix-screenshot-region" ''
        grim -g "$(slurp)"
      '';
      full = mkScreenshot "qnix-screenshot-full" "grim";
    in
    {
      home.packages = [
        region
        full
      ];

      wayland.windowManager.hyprland.settings.bind = [
        ", Print, exec, ${lib.getExe region}"
        "SHIFT, Print, exec, ${lib.getExe full}"
      ];
    };
}
