{
  lib,
  osConfig,
  pkgs,
  inputs,
  ...
}:

let
  cfg = osConfig.qnix.desktop.hyprdesktop.hyprsuite.ags;

  upstreamConfigDir = if cfg.configDir == null then inputs.qnix-ags.lib.configDir else cfg.configDir;

  # Required packages that must always be included
  requiredPackages = with inputs.ags.packages.${pkgs.system}; [
    hyprland
    battery
    wireplumber
    notifd
    tray
    mpris
  ];

  # Base packages from qnix-ags (includes required packages + others)
  basePackages = inputs.qnix-ags.lib.agsExtraPackages;

  # Merge: required packages + base packages + any user-provided extra packages
  # This ensures required packages are always included, even if basePackages changes
  allExtraPackages =
    requiredPackages
    ++ basePackages
    ++ cfg.extraPackages
    ++ [
      pkgs.libnotify
    ];

  # Use qnix.core.stylix.solarizedColors (converted from stylix base16)
  # Falls back to Solarized Dark defaults if stylix is not enabled or colors are empty
  solarizedColors = osConfig.qnix.core.stylix.solarizedColors or { };
  # Check if colors are actually populated (not empty strings)
  # If stylix.base16 is empty, solarizedColors will have empty strings
  # Check if base03 has a non-empty value to determine if colors are valid
  hasColors = (solarizedColors.base03 or "") != "";

  styling =
    if hasColors then
      solarizedColors
    else
      {
        base03 = "#002b36";
        base02 = "#073642";
        base01 = "#586e75";
        base00 = "#657b83";
        base0 = "#839496";
        base1 = "#93a1a1";
        base2 = "#eee8d5";
        base3 = "#fdf6e3";
        yellow = "#b58900";
        orange = "#cb4b16";
        red = "#dc322f";
        magenta = "#d33682";
        violet = "#6c71c4";
        blue = "#268bd2";
        cyan = "#2aa198";
        green = "#859900";
      };

  # Convert displays from {large: [...], small: [...]} to [{connector, left, condensed}, ...]
  displaysArray =
    (lib.map (connector: {
      connector = connector;
      left = true;
      condensed = false;
    }) cfg.displays.large)
    ++ (lib.map (connector: {
      connector = connector;
      left = true;
      condensed = true;
    }) cfg.displays.small);
in
{
  config = lib.mkIf cfg.enable {
    # Nix → AGS bridge: write a small JSON env file with values derived from
    # Nix options. We keep this separate from the AGS configDir so we don't
    # have to modify the flake checkout; AGS can read it from
    # ~/.config/ags-env/env.json.
    xdg.configFile."ags-env/env.json".text = builtins.toJSON {
      displays = displaysArray;
    };

    # Generate colors.scss from qnix.core.stylix.solarizedColors (converted from stylix)
    # Put it in ags-env to avoid conflicts with the symlinked configDir
    xdg.configFile."ags-env/colors.scss".text = ''
      // Colors from qnix.core.stylix.solarizedColors (converted from stylix base16)
      $base03: ${styling.base03};
      $base02: ${styling.base02};
      $base01: ${styling.base01};
      $base00: ${styling.base00};
      $base0: ${styling.base0};
      $base1: ${styling.base1};
      $base2: ${styling.base2};
      $base3: ${styling.base3};
      $yellow: ${styling.yellow};
      $orange: ${styling.orange};
      $red: ${styling.red};
      $magenta: ${styling.magenta};
      $violet: ${styling.violet};
      $blue: ${styling.blue};
      $cyan: ${styling.cyan};
      $green: ${styling.green};

      // Common aliases
      $bg: $base03;
      $bg-alt: $base02;
      $fg: $base0;
      $fg-alt: $base1;
      $border: $base01;
    '';

    # Enable the Home Manager AGS module, pointing it at the same directory.
    # HM will symlink ~/.config/ags for us via configDir, so we don't need to
    # manage that manually.
    programs.ags = {
      enable = true;
      configDir = upstreamConfigDir;

      systemd.enable = true;

      # Always include required packages (hyprland, battery, wireplumber) from qnix-ags,
      # plus any additional packages specified via qnix.hyprdesktop.ags.extraPackages.
      extraPackages = allExtraPackages;
    };
  };
}
