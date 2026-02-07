{ lib, config, ... }:

{
  options.qnix.desktop.hyprdesktop.ags = {
    enable = lib.mkEnableOption "ags" // {
      default = config.qnix.desktop.hyprdesktop.enable;
    };

    displays = {
      large = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Outputs that should use the wide AGS bar layout.";
        example = [
          "eDP-1"
          "HDMI-A-1"
        ];
      };

      small = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Outputs that should use the condensed AGS bar layout.";
        example = [ "DP-1" ];
      };
    };

    configDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the AGS configuration (git checkout of qnix-ags or similar). If null, the qnix-ags flake's configDir is used.";
      example = "/home/user/projects/qnix-ags";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to use when overriding ags in dev shells or elsewhere. Note: hyprland, battery, notifd, tray, and wireplumber are always included.";
    };
  };
}
