{ lib, pkgs ? null, isLaptop ? false, ... }:

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
      default = {
        base00 = "#001e26";
        base01 = "#002731";
        base02 = "#006388";
        base03 = "#3a8298";
        base04 = "#74a2a9";
        base05 = "#aec2ba";
        base06 = "#e9e2cb";
        base07 = "#fcf4dc";
        base08 = "#d01b24";
        base09 = "#a57705";
        base0A = "#178dc7";
        base0B = "#6bbe6c";
        base0C = "#259185";
        base0D = "#2075c7";
        base0E = "#c61b6e";
        base0F = "#680d12";
      };
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
  };
}
