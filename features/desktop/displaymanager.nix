{
  environments = [ "nixos" ];

  requires.nixos = [ "desktop.wayland" ];

  options =
    { lib, ... }:
    {
      sddm = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable SDDM.";
        };

        theme = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "sddm-astronaut-theme";
            description = "SDDM theme name.";
          };

          package = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = null;
            description = "Optional SDDM theme package.";
          };

          embeddedTheme = lib.mkOption {
            type = lib.types.str;
            default = "black_hole";
            description = "Embedded SDDM Astronaut theme variant.";
          };
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
    let
      themePackage =
        if cfg.sddm.theme.package != null then cfg.sddm.theme.package else pkgs.sddm-astronaut;
    in
    {
      assertions = [
        {
          assertion = !cfg.sddm.enable || cfg.enable;
          message = "SDDM cannot be enabled when desktop.displaymanager is disabled.";
        }
      ];

      environment.systemPackages = lib.mkIf cfg.sddm.enable [
        pkgs.kdePackages.qtmultimedia
        (themePackage.override { embeddedTheme = cfg.sddm.theme.embeddedTheme; })
      ];

      services.xserver.enable = lib.mkIf cfg.sddm.enable true;

      services.displayManager.sddm = lib.mkIf cfg.sddm.enable {
        enable = true;
        package = pkgs.kdePackages.sddm;
        theme = cfg.sddm.theme.name;
      };
    };
}
