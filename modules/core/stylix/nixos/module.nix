{
  lib,
  config,
  pkgs,
  ...
}:

let
  # Read from NixOS-level options (always available since stylix options are loaded in NixOS loader)
  cfg = config.qnix.core.stylix;
  cursorPackage = if cfg.cursor.package != null then cfg.cursor.package else pkgs.simp1e-cursors;
  iconPackage = if cfg.icons.package != null then cfg.icons.package else pkgs.fluent-icon-theme;
  serifPackage = if cfg.fonts.serif.package != null then cfg.fonts.serif.package else pkgs.fira-sans;
  sansSerifPackage = if cfg.fonts.sansSerif.package != null then cfg.fonts.sansSerif.package else pkgs.fira-sans;
  monospacePackage =
    if cfg.fonts.monospace.package != null then cfg.fonts.monospace.package else pkgs.nerd-fonts.jetbrains-mono;
  emojiPackage =
    if cfg.fonts.emoji.package != null then cfg.fonts.emoji.package else pkgs.noto-fonts-color-emoji;

  # Convert stylix base16 colors to solarized naming scheme
  # Takes config.stylix.base16 (from stylix) and returns colors in solarized format
  stylixToSolarized = base16: {
    # Base colors (direct mapping)
    base03 = base16.base03 or "";
    base02 = base16.base02 or "";
    base01 = base16.base01 or "";
    base00 = base16.base00 or "";

    # Light colors (base16 -> solarized mapping)
    base0 = base16.base04 or "";
    base1 = base16.base05 or "";
    base2 = base16.base06 or "";
    base3 = base16.base07 or "";

    # Accent colors (base16 -> solarized mapping)
    red = base16.base08 or "";
    orange = base16.base09 or "";
    yellow = base16.base0A or "";
    green = base16.base0B or "";
    cyan = base16.base0C or "";
    blue = base16.base0D or "";
    violet = base16.base0E or "";
    magenta = base16.base0F or "";
  };
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
        polarity = "dark";
        override = cfg.colorSchemeOverrides;
        cursor = {
          package = cursorPackage;
          name = cfg.cursor.name;
          size = cfg.cursor.size;
        };

        opacity = {
          applications = cfg.opacity.applications;
          terminal = cfg.opacity.terminal;
        };

        icons = {
          enable = true;

          package = iconPackage;
          dark = cfg.icons.dark;
          light = cfg.icons.light;
        };

        fonts = {
          serif = {
            package = serifPackage;
            name = cfg.fonts.serif.name;
          };

          sansSerif = {
            package = sansSerifPackage;
            name = cfg.fonts.sansSerif.name;
          };

          monospace = {
            package = monospacePackage;
            name = cfg.fonts.monospace.name;
          };

          emoji = {
            package = emojiPackage;
            name = cfg.fonts.emoji.name;
          };

          sizes = {
            applications = cfg.fonts.sizes.applications;
            desktop = cfg.fonts.sizes.desktop;
            popups = cfg.fonts.sizes.popups;
            terminal = cfg.fonts.sizes.terminal;
          };
        };
      };
    })
    # Expose computed solarized colors from stylix
    {
      qnix.core.stylix.solarizedColors = lib.mkIf (config.stylix.enable or false) (
        stylixToSolarized (config.stylix.base16 or { })
      );
    }
  ];
}
