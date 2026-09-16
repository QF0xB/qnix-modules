{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "security.gpg" ];

  persistence.users."*".directories = [
    ".config/git"
    ".config/gh"
  ];

  options =
    { lib, ... }:
    {
      lfs = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether Git LFS is enabled.";
      };

      signing = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Git signs commits by default.";
      };

      signingKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional GPG key used for Git commit signing.";
      };

      userName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Git user name.";
      };

      userEmail = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Git user email address.";
      };

      aliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Git aliases.";
      };

      extraConfig = lib.mkOption {
        type = lib.types.attrs;
        default = {
          push.autoSetupRemote = true;
        };
        description = "Additional Git configuration.";
      };

      githubTokenPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Runtime path to a GitHub token file used by the gh wrapper.";
      };
    };

  nixos =
    { ... }:
    { };

  home =
    {
      cfg,
      lib,
      osConfig ? null,
      pkgs,
      ...
    }:
    let
      githubTokenPath =
        if osConfig == null then
          cfg.githubTokenPath
        else
          lib.attrByPath [ "qnix" "dev" "git" "githubTokenPath" ] cfg.githubTokenPath osConfig;
      userName =
        if osConfig == null then
          cfg.userName
        else
          lib.attrByPath [ "qnix" "dev" "git" "userName" ] cfg.userName osConfig;
      userEmail =
        if osConfig == null then
          cfg.userEmail
        else
          lib.attrByPath [ "qnix" "dev" "git" "userEmail" ] cfg.userEmail osConfig;
      ghPackage =
        if githubTokenPath == null then
          pkgs.gh
        else
          pkgs.writeShellScriptBin "gh" ''
            export GH_TOKEN="$(<${lib.escapeShellArg githubTokenPath})"
            exec ${pkgs.gh}/bin/gh "$@"
          '';
    in
    {
      programs.git = {
        enable = true;
        lfs.enable = cfg.lfs;
        settings =
          cfg.extraConfig
          // {
            user =
              { }
              // lib.optionalAttrs (userName != null) { name = userName; }
              // lib.optionalAttrs (userEmail != null) { email = userEmail; };
          }
          // lib.optionalAttrs (cfg.aliases != { }) { alias = cfg.aliases; };
        signing = {
          key = cfg.signingKey;
          signByDefault = cfg.signing;
        };
      };

      programs.gh = {
        enable = true;
        package = ghPackage;
        settings.git_protocol = "ssh";
      };
    };
}
