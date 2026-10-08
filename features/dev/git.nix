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

      githubSshIdentityFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Runtime path to an SSH private key for github.com. When null, no GitHub SSH configuration is generated.";
      };

      githubSshIdentitiesOnly = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether GitHub SSH authentication uses only explicitly configured identities instead of offering unrelated agent keys. Applies when githubSshIdentityFile is set.";
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
      githubSshIdentityFile =
        if osConfig == null then
          cfg.githubSshIdentityFile
        else
          lib.attrByPath [ "qnix" "dev" "git" "githubSshIdentityFile" ] cfg.githubSshIdentityFile osConfig;
      githubSshIdentitiesOnly =
        if osConfig == null then
          cfg.githubSshIdentitiesOnly
        else
          lib.attrByPath [
            "qnix"
            "dev"
            "git"
            "githubSshIdentitiesOnly"
          ] cfg.githubSshIdentitiesOnly osConfig;
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

      programs.ssh = lib.mkIf (githubSshIdentityFile != null) {
        enable = true;
        enableDefaultConfig = lib.mkDefault false;
        settings."github.com" = {
          IdentityFile = githubSshIdentityFile;
          IdentitiesOnly = githubSshIdentitiesOnly;
        };
      };
    };
}
