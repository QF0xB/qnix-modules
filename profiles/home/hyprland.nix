{
  lib,
  qnixLib,
  qnixHomeStandalone ? false,
  ...
}:
let
  sharedQnix = import ../shared/hyprland.nix { inherit lib; };
in
{
  imports = [
    ./wayland.nix
  ]
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "hyprland";
    name = "hyprland";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "hyprland";
    name = "keybinds";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "hyprland";
    name = "rules";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "hyprland";
    name = "special-workspaces";
  })
  ++ (qnixLib.qnix.mkHomeFeatureImports {
    category = "desktop";
    name = "noctalia";
  });

  config = lib.mkIf qnixHomeStandalone {
    qnix = sharedQnix;
  };
}
