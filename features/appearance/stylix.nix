{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  options =
    {
      lib,
      pkgs,
      ...
    }:
    {
      colorScheme = lib.mkOption {
        type = lib.types.str;
        default = "solarized-dark";
        description = "Base16 color scheme name from base16-schemes.";
      };

      colorSchemeOverrides = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Stylix Base16 color overrides.";
      };

      cursor = {
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = pkgs.simp1e-cursors;
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
          default = 0.8;
        };
      };

      icons = {
        enable = lib.mkEnableOption "Stylix icon theme integration" // {
          default = true;
        };
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = pkgs.fluent-icon-theme;
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
            default = pkgs.fira-sans;
          };
          name = lib.mkOption {
            type = lib.types.str;
            default = "Fira Sans";
          };
        };
        sansSerif = {
          package = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = pkgs.fira-sans;
          };
          name = lib.mkOption {
            type = lib.types.str;
            default = "Fira Sans";
          };
        };
        monospace = {
          package = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = pkgs.nerd-fonts.jetbrains-mono;
          };
          name = lib.mkOption {
            type = lib.types.str;
            default = "JetBrains Mono Nerd Font";
          };
        };
        emoji = {
          package = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = pkgs.noto-fonts-color-emoji;
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
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Directory copied to ~/Pictures/wallpaper when enabled.";
        };
      };
    };

  nixos =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf cfg.enable {
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
        polarity = "dark";
        override = cfg.colorSchemeOverrides;
        cursor = { inherit (cfg.cursor) package name size; };
        opacity = cfg.opacity;
        icons = lib.mkIf cfg.icons.enable {
          enable = true;
          inherit (cfg.icons) package dark light;
        };
        fonts = cfg.fonts;
      };
    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf cfg.enable {
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
        polarity = "dark";
        override = cfg.colorSchemeOverrides;
        targets = {
          kitty.variant256Colors = true;
          vencord.enable = false;
          vesktop.enable = false;
          nixcord.enable = false;
        };
        cursor = { inherit (cfg.cursor) package name size; };
        opacity = cfg.opacity;
        icons = lib.mkIf cfg.icons.enable {
          enable = true;
          inherit (cfg.icons) package dark light;
        };
        fonts = cfg.fonts;
      };

      home.file."Pictures/wallpaper" =
        lib.mkIf (cfg.wallpapers.enable && cfg.wallpapers.wallpapersPath != null)
          {
            source = cfg.wallpapers.wallpapersPath;
            recursive = true;
          };
    };
}
