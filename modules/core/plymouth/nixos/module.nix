{
  lib,
  config,
  pkgs,
  ...
}:

let
  # Options can be in NixOS (system-wide, if loadOptions=true) or home-manager (via config.hm.qnix.*)
  # Check system-wide first, fallback to home-manager for flexibility (e.g., servers without home-manager)
  cfg = config.qnix.core.plymouth or config.hm.qnix.core.plymouth;
in
{
  config = lib.mkIf cfg.enable {
    stylix.targets.plymouth.enable = false;

    boot = {
      plymouth = {
        enable = true;
        theme = "nixos-blur";
        # Use the package from overlay if available, otherwise fallback to null (will fail with clear error)
        themePackages = [
          (pkgs.qnix-pkgs.nixos-blur
            or (throw "nixos-blur package not found. Make sure qnix-pkgs overlay is applied.")
          )
        ];
      };

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
