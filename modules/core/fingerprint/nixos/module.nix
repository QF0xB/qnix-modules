{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.qnix.core.fingerprint;
in
{
  config = lib.mkIf cfg.enable {
    services.fprintd = {
      enable = true;
      tod = lib.mkIf (cfg.tod.enable && cfg.tod.driver != null) {
        enable = true;
        driver = cfg.tod.driver;
      };
    };

    # PAM: enable fingerprint auth for login and sudo when requested
    security.pam.services = lib.mkMerge [
      (lib.mkIf cfg.login {
        login.fprintAuth = true;
        # Common display managers
        sddm.fprintAuth = true;
        lightdm.fprintAuth = true;
      })
      (lib.mkIf cfg.sudo {
        sudo.fprintAuth = true;
      })
    ];

    qnix.persist.root.directories = [
      "/var/lib/fprint"
    ];
  };
}
