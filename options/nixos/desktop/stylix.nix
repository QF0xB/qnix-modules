{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.stylix = {
    enable = lib.mkEnableOption "Stylix";

    colorScheme = lib.mkOption {
      type = lib.types.str;
      default = "solarized-dark";
      description = "Base16 color scheme name from base16-schemes.";
    };

    colorSchemeOverrides = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Stylix base16 overrides.";
    };

    cursor = {
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        defaultText = lib.literalExpression "pkgs.simp1e-cursors";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "Simp1e-Solarized-Dark";
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 24;
      };
    };

    opacity = {
      applications = lib.mkOption {
        type = lib.types.float;
        default = 0.5;
      };

      terminal = lib.mkOption {
        type = lib.types.float;
        default = 0.5;
      };
    };

    icons = {
      enable = lib.mkEnableOption "Stylix icon theme integration" // {
        default = true;
      };

      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        defaultText = lib.literalExpression "pkgs.fluent-icon-theme";
      };

      dark = lib.mkOption {
        type = lib.types.str;
        default = "Fluent-dark";
      };

      light = lib.mkOption {
        type = lib.types.str;
        default = "Fluent-light";
      };
    };

    fonts = {
      serif = {
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          defaultText = lib.literalExpression "pkgs.fira-sans";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "Fira Sans";
        };
      };

      sansSerif = {
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          defaultText = lib.literalExpression "pkgs.fira-sans";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "Fira Sans";
        };
      };

      monospace = {
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          defaultText = lib.literalExpression "pkgs.nerd-fonts.jetbrains-mono";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "JetBrains Mono Nerd Font";
        };
      };

      emoji = {
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          defaultText = lib.literalExpression "pkgs.noto-fonts-color-emoji";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "Noto Color Emoji";
        };
      };

      sizes = {
        applications = lib.mkOption {
          type = lib.types.int;
          default = 16;
        };

        desktop = lib.mkOption {
          type = lib.types.int;
          default = 16;
        };

        popups = lib.mkOption {
          type = lib.types.int;
          default = 16;
        };

        terminal = lib.mkOption {
          type = lib.types.int;
          default = 16;
        };
      };
    };

    wallpapers = {
      enable = lib.mkEnableOption "Stylix wallpaper directory sync";

      wallpapersPath = lib.mkOption {
        type = lib.types.path;
        default = ../../../assets/wallpapers;
        description = "Directory copied to ~/Pictures/wallpaper when enabled.";
      };
    };

    solarizedColors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      default = { };
    };
  };
}
