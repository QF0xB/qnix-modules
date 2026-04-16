{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.runtime.flux = {
    enable = lib.mkEnableOption "Flux GitOps tooling";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fluxcd;
      defaultText = lib.literalExpression "pkgs.fluxcd";
      description = "Flux CLI package.";
    };

    namespace = lib.mkOption {
      type = lib.types.str;
      default = "flux-system";
      description = "Namespace used by Flux controllers.";
    };

    gitRepository = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "ssh://git@github.com/example/platform.git";
      description = "Git repository URL used for Flux bootstrap helper.";
    };

    gitBranch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Git branch used for Flux bootstrap helper.";
    };

    gitPath = lib.mkOption {
      type = lib.types.str;
      default = "./clusters/default";
      description = "Path inside the Git repository used for Flux bootstrap helper.";
    };

    privateKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional SSH private key path passed to flux bootstrap for private repositories.";
    };

    privateKeySopsSecretName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "flux-deploy-key";
      description = "Optional qnix.security.sops.secrets entry name used as the Flux private key source.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional passphrase file used with privateKeyFile.";
    };

    passwordSopsSecretName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "flux-deploy-key-passphrase";
      description = "Optional qnix.security.sops.secrets entry name used as Flux private key passphrase source.";
    };

    extraBootstrapArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional arguments appended to the `flux bootstrap git` command.";
    };
  };
}
