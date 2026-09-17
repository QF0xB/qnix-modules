{ ctx }:
with ctx;
assert
  gpgFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert gpgNixosEvaluation.config.programs.gnupg.agent.enable;
assert !gpgNixosEvaluation.config.programs.gnupg.agent.enableSSHSupport;
assert gpgNixosEvaluation.config.qnix.persist.users."*".directories == [ ".gnupg" ];
assert gpgHomeEvaluation.config.programs.gpg.enable;
assert gpgHomeEvaluation.config.services.gpg-agent.enable;
assert !gpgHomeEvaluation.config.services.gpg-agent.enableSshSupport;
assert gpgHomeEvaluation.config.programs.gpg.settings.use-agent;
assert builtins.length gpgHomeEvaluation.config.programs.gpg.publicKeys == 1;
assert
  (builtins.elemAt gpgHomeEvaluation.config.programs.gpg.publicKeys 0).text == "test-public-key";
assert (builtins.elemAt gpgHomeEvaluation.config.programs.gpg.publicKeys 0).trust == 4;
assert gnomeKeyringFeature.supportedEnvironments == [ "nixos" ];
assert gnomeKeyringEvaluation.config.services.gnome.gnome-keyring.enable;
assert gnomeKeyringEvaluation.config.security.pam.services.login.enableGnomeKeyring;
assert gnomeKeyringEvaluation.config.security.pam.services.sddm.enableGnomeKeyring;
assert
  gnomeKeyringEvaluation.config.qnix.persist.users."*".directories == [ ".local/share/keyrings" ];
assert !(builtins.elem pkgs.seahorse gnomeKeyringEvaluation.config.environment.systemPackages);
assert builtins.elem pkgs.seahorse gnomeKeyringGuiEvaluation.config.environment.systemPackages;
assert polkitFeature.supportedEnvironments == [ "nixos" ];
assert polkitEvaluation.config.security.polkit.enable;
assert polkitEvaluation.config.qnix.security.polkit.allowUserPowerCommands;
assert
  builtins.match ".*org.freedesktop.login1.reboot.*" polkitEvaluation.config.security.polkit.extraConfig
  != null;
assert !polkitDisabledEvaluation.config.qnix.security.polkit.allowUserPowerCommands;
assert
  builtins.match ".*org.freedesktop.login1.reboot.*" polkitDisabledEvaluation.config.security.polkit.extraConfig
  == null;
assert sopsFeature.supportedEnvironments == [ "nixos" ];
assert secretsProfileEvaluation.config.qnix.security.sops.validateSopsFiles == false;
assert secretsProfileEvaluation.config.sops.validateSopsFiles == false;
assert sopsEvaluation.config.sops.defaultSopsFile == /dev/null;
assert !sopsEvaluation.config.sops.validateSopsFiles;
assert sopsEvaluation.config.sops.age.generateKey;
assert sopsEvaluation.config.sops.age.keyFile == "/var/lib/sops/age/keys.txt";
assert sopsEvaluation.config.sops.secrets.example.key == "example";
assert sopsEvaluation.config.sops.secrets.example.path == "/run/secrets/example";
assert sopsEvaluation.config.sops.secrets.example.owner == "check";
assert sopsEvaluation.config.sops.secrets.example.group == "users";
assert sopsEvaluation.config.sops.secrets.example.mode == "0440";
assert sopsEvaluation.config.sops.secrets.example.neededForUsers;
assert sopsEvaluation.config.sops.secrets.example.restartUnits == [ "example.service" ];
assert yubikeyFeature.supportedEnvironments == [ "nixos" ];
assert yubikeyEvaluation.config.services.pcscd.enable;
assert yubikeyEvaluation.config.hardware.gpgSmartcards.enable;
assert yubikeyEvaluation.config.security.pam.u2f.enable;
assert yubikeyEvaluation.config.security.pam.u2f.settings.cue == false;
assert yubikeyEvaluation.config.security.pam.u2f.settings.origin == "pam://check";
assert yubikeyEvaluation.config.security.pam.services.login.u2f.enable;
assert yubikeyEvaluation.config.security.pam.services.sudo.u2f.enable;
assert yubikeyEvaluation.config.qnix.security.yubikey.gui;
assert builtins.elem pkgs.yubioath-flutter yubikeyEvaluation.config.environment.systemPackages;
pkgs.runCommand "qnix-security-check" { } "touch $out"
