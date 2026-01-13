{ lib, config, ... }:

let
  cfg = config.qnix.core.git;
in
{
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      signing = lib.mkIf cfg.signing {
        key = cfg.signingKey;
        signByDefault = true;
      };

      extraConfig = {
        core = {
          editor = "nvim";
        };
      };
    };
  };
}
