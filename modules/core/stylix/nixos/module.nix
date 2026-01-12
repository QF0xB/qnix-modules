{ lib, config, ... }:

let
  cfg = config.hm.qnix.core.stylix;
in
{
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;

      # base16Scheme = "${pkgs.base16-schemes}/share/themes/solarized-dark.yaml";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";

      override = cfg.colorSchemeOverrides;

      cursor = {
        package = cfg.cursor.package;
        name = cfg.cursor.name;
        size = cfg.cursor.size;
      };

      opacity = {
        applications = cfg.opacity.applications;
        terminal = cfg.opacity.terminal;
      };
      
      icons = {
        enable = true;

        package = cfg.icons.package;
        dark = cfg.icons.dark;
        light = cfg.icons.light;
      };

      fonts = {
        serif = {
          package = cfg.fonts.serif.package;
          name = cfg.fonts.serif.name;
        };

        sansSerif = {
          package = cfg.fonts.sansSerif.package;
          name = cfg.fonts.sansSerif.name;
        };

        monospace = {
          package = cfg.fonts.monospace.package;
          name = cfg.fonts.monospace.name;
        };

        emoji = {
          package = cfg.fonts.emoji.package;
          name = cfg.fonts.emoji.name;
        };

        sizes = {
          applications = cfg.fonts.sizes.applications;
          desktop = cfg.fonts.sizes.desktop;
          popups = cfg.fonts.sizes.popups;
          terminal = cfg.fonts.sizes.terminal;
        };
      };
    }
  };
}
