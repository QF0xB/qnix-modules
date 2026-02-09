{
  osConfig,
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  cfg = osConfig.qnix.desktop.hyprdesktop.noctalia;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
      settings = {
        # configure noctalia here
        bar = {
          density = "simple";
          position = "left";
          showCapsule = false;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                id = "Launcher";
              }
              {
                id = "Network";
              }
              {
                id = "Bluetooth";
              }
            ];
            center = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                alwaysShowPercentage = false;
                id = "Battery";
                warningThreshold = 30;
              }
              {
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
            ];
          };
        };
        colorSchemes.predefinedScheme = "Monochrome";
        general = {
          avatarImage = "${config.home.homeDirectory}/.face";
          radiusRatio = 0.2;
        };
        location = {
          monthBeforeDay = false;
          name = "Munich, Germany";
        };
      };
    };

  };
}
