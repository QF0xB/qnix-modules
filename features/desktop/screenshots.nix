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
        default = "Pictures/Screenshots";
        description = "Screenshot directory, relative to the home directory unless absolute.";
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
      config,
      lib,
      pkgs,
      ...
    }:
    let
      outputDirectory =
        if lib.hasPrefix "/" cfg.outputDirectory then
          cfg.outputDirectory
        else
          "${config.home.homeDirectory}/${cfg.outputDirectory}";
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
            directory=${lib.escapeShellArg outputDirectory}
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

      wayland.windowManager.hyprland.settings.on = [
        {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''
              function()
                hl.exec_cmd(${
                  lib.generators.toLua { }
                    "hyprctl keyword bind ${lib.escapeShellArg ", Print, exec, ${lib.getExe region}"}"
                })
                hl.exec_cmd(${
                  lib.generators.toLua { }
                    "hyprctl keyword bind ${lib.escapeShellArg "SHIFT, Print, exec, ${lib.getExe full}"}"
                })
              end
            '')
          ];
        }
      ];
    };
}
