{ lib, ... }:

{
  config = {
    home.activation.createHyprMonitorConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "/persist/home/$USER/.config/hypr/monitors.conf" ]; then
        mkdir -p "/persist/home/$USER/.config/hypr"
        cat > "/persist/home/$USER/.config/hypr/monitors.conf" << EOF
      # Default Hyprland monitor configuration
      # This uses the first detected monitor with preferred resolution
      # If you have issues with mouse boundaries, run: hyprctl monitors
      # Then update this file with the correct monitor configuration
      monitor = , preferred, auto, 1
      EOF
      fi
      if [ ! -f "/persist/home/$USER/.config/hypr/workspaces.conf" ]; then
        mkdir -p "/persist/home/$USER/.config/hypr"
        touch "/persist/home/$USER/.config/hypr/workspaces.conf"
      fi
    '';
  };
}
