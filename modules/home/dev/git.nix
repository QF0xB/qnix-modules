{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg =
    if lib.hasAttrByPath [ "dev" "git" ] qconfig then
      qconfig.dev.git
    else
      {
        enable = false;
      };
in
{
  config = lib.mkIf cfg.enable {
    programs.git = lib.mkMerge [
      {
        enable = true;
        lfs.enable = cfg.lfs;
        settings = lib.mkMerge [
          cfg.extraConfig
          (lib.optionalAttrs (cfg.aliases != { }) {
            alias = cfg.aliases;
          })
          (lib.optionalAttrs (cfg.userName != null || cfg.userEmail != null) {
            user = { }
            // lib.optionalAttrs (cfg.userName != null) {
              name = cfg.userName;
            }
            // lib.optionalAttrs (cfg.userEmail != null) {
              email = cfg.userEmail;
            };
          })
        ];
        signing = {
          key = cfg.signingKey;
          signByDefault = cfg.signing;
        };
      }
    ];
  };
}
