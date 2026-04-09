{ lib, ... }:
{
  options.qnix.desktop.hyprland.specialWorkspaces.enable =
    lib.mkEnableOption "Hyprland special workspace defaults"
    // {
      default = true;
    };
}
