{
  lib,
  config,
  osConfig,
  ...
}:

let
  cfg = osConfig.qnix.core.git;
in
{
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      lfs.enable = cfg.lfs;

      signing = lib.mkIf cfg.signing {
        key = cfg.signingKey;
        signByDefault = true;
      };

      settings = {
        core = {
          editor = "nvim";
        };

        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };

        commit.gpgSign = cfg.signing;
      };
    };
  };
}
