{ lib, user, ... }:

{
  options.qnix.core.git = {
    enable = lib.mkEnableOption "git" // {
      default = true;
    };

    userName = lib.mkOption {
      type = lib.types.str;
      description = "The name to use for git commits";
      default = "";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "The email to use for git commits";
      default = "";
    };

    signing = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to enable git signing";
      default = false;
    };

    signingKey = lib.mkOption {
      type = lib.types.str;
      description = "The key to use for git signing";
      default = "";
    };
}
