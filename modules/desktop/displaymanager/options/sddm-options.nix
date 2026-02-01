{
  lib,
  pkgs,
  ...
}:

{
  options.qnix.desktop.displaymanager.sddm = with lib; {
    enable = mkEnableOption "SDDM display manager" // {
      default = true;
    };

    theme = {
      name = mkOption {
        type = types.str;
        default = "sddm-astronaut-theme";
        description = "SDDM theme name";
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = pkgs.sddm-astronaut;
        description = "SDDM theme package";
      };

      embeddedTheme = mkOption {
        type = types.str;
        default = "black_hole";
        description = "Embedded theme variant for the theme package";
      };
    };
  };
}
