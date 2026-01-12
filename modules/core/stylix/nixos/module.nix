{ lib, config, pkgs, ... }:

let
  # Try to get user from home-manager config
  # This avoids using the alias which might not be set up yet
  homeManagerUsers = config.home-manager.users or {};
  # Get the first (and typically only) user
  userKeys = lib.attrNames homeManagerUsers;
  firstUser = if userKeys != [] then lib.head userKeys else null;
  
  # Safely access stylix config
  stylixCfg = if firstUser != null && lib.hasAttr "qnix" (homeManagerUsers.${firstUser} or {}) then
    (homeManagerUsers.${firstUser}.qnix.core.stylix or { enable = false; })
  else
    { enable = false; };
in
{
  config = lib.mkMerge [
    (lib.mkIf stylixCfg.enable {
      stylix = {
        enable = true;

        base16Scheme = "${pkgs.base16-schemes}/share/themes/${stylixCfg.colorScheme}.yaml";

        override = stylixCfg.colorSchemeOverrides or {};

        cursor = {
          package = stylixCfg.cursor.package or null;
          name = stylixCfg.cursor.name or null;
          size = stylixCfg.cursor.size or null;
        };

        opacity = {
          applications = stylixCfg.opacity.applications or null;
          terminal = stylixCfg.opacity.terminal or null;
        };
        
        icons = {
          enable = true;

          package = stylixCfg.icons.package or null;
          dark = stylixCfg.icons.dark or null;
          light = stylixCfg.icons.light or null;
        };

        fonts = {
          serif = {
            package = stylixCfg.fonts.serif.package or null;
            name = stylixCfg.fonts.serif.name or null;
          };

          sansSerif = {
            package = stylixCfg.fonts.sansSerif.package or null;
            name = stylixCfg.fonts.sansSerif.name or null;
          };

          monospace = {
            package = stylixCfg.fonts.monospace.package or null;
            name = stylixCfg.fonts.monospace.name or null;
          };

          emoji = {
            package = stylixCfg.fonts.emoji.package or null;
            name = stylixCfg.fonts.emoji.name or null;
          };

          sizes = {
            applications = stylixCfg.fonts.sizes.applications or null;
            desktop = stylixCfg.fonts.sizes.desktop or null;
            popups = stylixCfg.fonts.sizes.popups or null;
            terminal = stylixCfg.fonts.sizes.terminal or null;
          };
        };
      };
    })
  ];
}