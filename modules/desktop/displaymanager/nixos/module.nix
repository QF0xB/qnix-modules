{
  lib,
  config,
  ...
}:

let
  cfg = config.qnix.desktop.displaymanager;
in
{
  imports = [
    ./sddm.nix
  ];

  # Ensure only one display manager is enabled
  assertions = [
    {
      assertion =
        lib.count (x: x) [
          cfg.sddm.enable
          # Add more display managers here as they are implemented
          # cfg.gdm.enable
          # cfg.lightdm.enable
        ] <= 1;
      message = "Only one display manager can be enabled at a time.";
    }
    {
      assertion = !cfg.sddm.enable || cfg.enable;
      message = "Display manager module must be enabled (qnix.desktop.displaymanager.enable = true) to use SDDM.";
    }
  ];
}
