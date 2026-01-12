{ lib, pkgs ? null, isLaptop ? false, ... }:

let
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
  options.qnix.core.stylix = {
    enable = lib.mkEnableOption "stylix" // {
      default = true;
    };

    colorScheme = lib.mkOption {
      type = lib.types.str;
      default = "solarized-dark";
      description = "The color scheme to use, must be in base16scheme repo";
    };

    colorSchemeOverrides = lib.mkOption {
      type = lib.types.attrs;
      description = "Override the color scheme with custom colors";
      default = {};
    };

    cursor = lib.mkOption {
      type = lib.types.attrs;
      description = "The cursor to use";
      default = {
        package = if pkgs != null then pkgs.simp1e-cursors else null;
        name = "Simp1e-Solarized-Dark";
        size = 24;
      };
    };

    opacity = {
      applications = lib.mkOption {
        type = lib.types.float;
        description = "The opacity of the applications";
        default = 0.5;
      };
      terminal = lib.mkOption {
        type = lib.types.float;
        description = "The opacity of the terminal";
        default = 0.5;
      };
    };

    icons = lib.mkOption {
      type = lib.types.attrs;
      description = "The icons to use";
      default = {
        enable = true;
        package = if pkgs != null then pkgs.fluent-icon-theme else null;
        dark = "Fluent-dark";
        light = "Fluent-light";
      };
    };

    fonts = {
      serif = lib.mkOption {
        type = lib.types.attrs;
        description = "The serif font to use";
        default = {
          package = if pkgs != null then pkgs.fira-sans else null;
          name = "Fira Sans";
        };
      };

      sansSerif = lib.mkOption {
        type = lib.types.attrs;
        description = "The sans-serif font to use";
        default = {
          package = if pkgs != null then pkgs.fira-sans else null;
          name = "Fira Sans";
        };
      };

      monospace = lib.mkOption {
        type = lib.types.attrs;
        description = "The monospace font to use";
        default = {
          package = if pkgs != null then pkgs.nerd-fonts.jetbrains-mono else null;
          name = "JetBrains Mono Nerd Font";
        };
      };

      emoji = lib.mkOption {
        type = lib.types.attrs;
        description = "The emoji font to use";
        default = {
          package = if pkgs != null then pkgs.noto-fonts-color-emoji else null;
          name = "Noto Color Emoji";
        };
      };

      sizes = lib.mkOption {
        type = lib.types.attrs;
        description = "The sizes of the fonts";
        default = {
          applications = (if isLaptop then 12 else 16);
          desktop = (if isLaptop then 12 else 16);
          popups = (if isLaptop then 12 else 16);
          terminal = (if isLaptop then 12 else 16);
        };
      };
    };

    # Solarized colors converted from stylix base16 colors
    # Automatically computed when stylix is enabled
    solarizedColors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Colors converted from stylix base16 to solarized naming scheme (base03, base02, base01, base00, base0, base1, base2, base3, red, orange, yellow, green, cyan, blue, violet, magenta)";
      default = {};
      readOnly = true;
    };
  };
}
