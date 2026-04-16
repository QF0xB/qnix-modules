{
  lib,
  config,
  pkgs,
  options,
  ...
}:
let
  cfg = config.qnix.runtime.flux;
  defaultRepository = if cfg.gitRepository == null then "" else cfg.gitRepository;
  extraArgs = lib.concatMapStringsSep " " lib.escapeShellArg cfg.extraBootstrapArgs;
  privateKeyPath =
    if cfg.privateKeyFile != null then
      toString cfg.privateKeyFile
    else if
      cfg.privateKeySopsSecretName != null
      && config.qnix.security.sops.enable
      && options ? sops
      && lib.hasAttrByPath [ "secrets" cfg.privateKeySopsSecretName ] config.sops
    then
      config.sops.secrets.${cfg.privateKeySopsSecretName}.path
    else
      null;
  passwordPath =
    if cfg.passwordFile != null then
      toString cfg.passwordFile
    else if
      cfg.passwordSopsSecretName != null
      && config.qnix.security.sops.enable
      && options ? sops
      && lib.hasAttrByPath [ "secrets" cfg.passwordSopsSecretName ] config.sops
    then
      config.sops.secrets.${cfg.passwordSopsSecretName}.path
    else
      null;
  bootstrapScript = pkgs.writeShellApplication {
    name = "qnix-flux-bootstrap";
    runtimeInputs = [
      cfg.package
      pkgs.kubectl
    ];
    text = ''
      set -euo pipefail

      if [ -z "''${GIT_REPOSITORY:-}" ]; then
        if [ -n "${defaultRepository}" ]; then
          GIT_REPOSITORY="${defaultRepository}"
        else
          echo "Set GIT_REPOSITORY or qnix.runtime.flux.gitRepository."
          exit 1
        fi
      fi

      private_key_args=()
      password_args=()
      extra_args=(${extraArgs})

      ${lib.optionalString (privateKeyPath != null) ''
        private_key_args=(--private-key-file "${privateKeyPath}")
      ''}
      ${lib.optionalString (passwordPath != null) ''
        password_args=(--password-file "${passwordPath}")
      ''}

      flux bootstrap git \
        --url="$GIT_REPOSITORY" \
        --branch="${cfg.gitBranch}" \
        --path="${cfg.gitPath}" \
        --namespace="${cfg.namespace}" \
        ''${private_key_args[@]} \
        ''${password_args[@]} \
        ''${extra_args[@]}
    '';
  };
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.privateKeyFile != null && cfg.privateKeySopsSecretName != null);
        message = "Set either qnix.runtime.flux.privateKeyFile or privateKeySopsSecretName, not both.";
      }
      {
        assertion = !(cfg.passwordFile != null && cfg.passwordSopsSecretName != null);
        message = "Set either qnix.runtime.flux.passwordFile or passwordSopsSecretName, not both.";
      }
      {
        assertion = cfg.privateKeySopsSecretName == null || config.qnix.security.sops.enable;
        message = "qnix.runtime.flux.privateKeySopsSecretName requires qnix.security.sops.enable.";
      }
      {
        assertion =
          cfg.privateKeySopsSecretName == null
          || (options ? sops && lib.hasAttrByPath [ "secrets" cfg.privateKeySopsSecretName ] config.sops);
        message = "Flux private key SOPS secret not found in config.sops.secrets.";
      }
      {
        assertion = cfg.passwordSopsSecretName == null || config.qnix.security.sops.enable;
        message = "qnix.runtime.flux.passwordSopsSecretName requires qnix.security.sops.enable.";
      }
      {
        assertion =
          cfg.passwordSopsSecretName == null
          || (options ? sops && lib.hasAttrByPath [ "secrets" cfg.passwordSopsSecretName ] config.sops);
        message = "Flux password SOPS secret not found in config.sops.secrets.";
      }
    ];

    qnix.security.sops.secrets =
      lib.optionalAttrs (cfg.privateKeySopsSecretName != null) {
        "${cfg.privateKeySopsSecretName}" = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
      }
      // lib.optionalAttrs (cfg.passwordSopsSecretName != null) {
        "${cfg.passwordSopsSecretName}" = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };

    environment.systemPackages = [
      cfg.package
      bootstrapScript
    ];
  };
}
