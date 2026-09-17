{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [
    "desktop.hyprland"
    "desktop.xdg-folders"
  ];

  persistence.users."*".directories = [ "Pictures/Screenshots" ];

  options =
    { lib, ... }:
    {
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
      outputDirectory = "${config.home.homeDirectory}/Pictures/Screenshots";
      mkScreenshot =
        name: capture:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [
            pkgs.coreutils
            pkgs.grim
            pkgs.libnotify
            pkgs.slurp
            pkgs.wl-clipboard
          ];
          text = ''
            directory=${lib.escapeShellArg outputDirectory}
            filename="$directory/$(date +%Y-%m-%d_%H-%M-%S).png"

            mkdir -p "$directory"
            ${capture} "$filename"
            ${lib.optionalString cfg.copyToClipboard "wl-copy --type image/png < \"$filename\""}
            notify-send --app-name="Screenshots" --icon="$filename" \
              "Screenshot saved" "$filename"
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
        {
          _args = [
            "Print"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua { } (lib.getExe full)})")
          ];
        }
        {
          _args = [
            "SHIFT + Print"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua { } (lib.getExe region)})")
          ];
        }
      ];
    };
}
