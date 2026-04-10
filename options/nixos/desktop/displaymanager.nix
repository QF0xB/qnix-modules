{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.displaymanager = {
    enable = lib.mkEnableOption "display manager";

    sddm = {
      enable = lib.mkEnableOption "SDDM display manager";

      theme = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "sddm-astronaut-theme";
          description = "SDDM theme name";
        };

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          defaultText = lib.literalExpression "pkgs.sddm-astronaut";
          description = "SDDM theme package";
        };

        embeddedTheme = lib.mkOption {
          type = lib.types.str;
          default = "black_hole";
          description = "Embedded SDDM theme variant";
        };
      };
    };
  };
}
