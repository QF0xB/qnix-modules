{ lib, config, ... }:

let
  cfg = config.qnix.core.git;
in
{
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings.user = {
        name = cfg.userName;
        email = cfg.userEmail;
      };
      signing = lib.mkIf cfg.signing {
        key = cfg.signingKey;
        signByDefault = true;
      };

      settings = {
        core = {
          editor = "nvim";
        };
      };
    };
  };
}
