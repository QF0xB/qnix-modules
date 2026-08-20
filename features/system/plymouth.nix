{
  environments = [ "nixos" ];

  options =
    {
      lib,
      pkgs,
      ...
    }:
    let
      hasNixosBlur = pkgs ? qnix-pkgs && pkgs.qnix-pkgs ? nixos-blur;
    in
    {
      theme = lib.mkOption {
        type = lib.types.str;
        default = if hasNixosBlur then "nixos-blur" else "nixos-bgrt";
        description = "Plymouth splash screen theme.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = if hasNixosBlur then pkgs.qnix-pkgs.nixos-blur else pkgs.nixos-bgrt-plymouth;
        description = "Package providing the configured Plymouth theme.";
      };

      quietBoot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to reduce kernel and initrd output during boot.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      options,
      ...
    }:
    lib.optionalAttrs (lib.hasAttrByPath [ "stylix" "targets" "plymouth" "enable" ] options) {
      stylix.targets.plymouth.enable = false;
    }
    // {
      boot = lib.mkMerge [
        {
          plymouth = {
            enable = true;
            theme = cfg.theme;
            themePackages = [ cfg.package ];
          };
        }
        (lib.mkIf cfg.quietBoot {
          consoleLogLevel = 3;
          initrd.verbose = false;
          kernelParams = [
            "quiet"
            "splash"
            "boot.shell_on_fail"
            "udev.log_priority=3"
            "rd.systemd.show_status=auto"
          ];
        })
      ];
    };
}
