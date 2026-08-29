{ ctx }:
with ctx;
assert persistFeature.supportedEnvironments == [ "nixos" ];
assert bootFeature.supportedEnvironments == [ "nixos" ];
assert plymouthFeature.supportedEnvironments == [ "nixos" ];
assert
  localisationFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert plymouthEvaluation.config.boot.plymouth.enable;
assert plymouthEvaluation.config.boot.plymouth.theme == "nixos-bgrt";
assert plymouthEvaluation.config.boot.plymouth.themePackages == [ pkgs.nixos-bgrt-plymouth ];
assert plymouthEvaluation.config.boot.consoleLogLevel == 3;
assert !plymouthEvaluation.config.boot.initrd.verbose;
assert plymouthEvaluation.config.stylix.targets.plymouth.enable == false;
assert bootEvaluation.config.boot.loader.systemd-boot.enable;
assert bootEvaluation.config.boot.loader.timeout == 3;
assert bootEvaluation.config.boot.supportedFilesystems.zfs;
assert bootEvaluation.config.boot.initrd.systemd.enable;
assert grubBootEvaluation.config.boot.loader.grub.enable;
assert grubBootEvaluation.config.boot.loader.grub.enableCryptodisk;
assert !(grubBootEvaluation.config.boot.supportedFilesystems ? zfs);
assert userFeature.supportedEnvironments == [ "nixos" ];
assert userEvaluation.config.users.mutableUsers == false;
assert userEvaluation.config.users.defaultUserShell == pkgs.bash;
assert userEvaluation.config.users.users.root.isSystemUser;
assert userEvaluation.config.users.users.alice.isNormalUser;
assert userEvaluation.config.users.users.alice.group == "alice";
assert
  userEvaluation.config.users.users.alice.extraGroups == [
    "wheel"
    "audio"
  ];
assert userEvaluation.config.users.users.alice.home == "/home/alice";
assert userEvaluation.config.users.users.alice.description == "Alice";
assert userEvaluation.config.users.users.alice.shell == pkgs.zsh;
assert
  userEvaluation.config.users.users.alice.openssh.authorizedKeys.keys == [ "ssh-ed25519 AAAA alice" ];
assert userEvaluation.config.users.users.service.isSystemUser;
assert userEvaluation.config.users.users.service.group == "svc";
assert builtins.hasAttr "alice" userEvaluation.config.users.groups;
assert builtins.hasAttr "svc" userEvaluation.config.users.groups;
assert nhFeature.supportedEnvironments == [ "nixos" ];
assert nhEvaluation.config.programs.nh.enable;
assert nhEvaluation.config.programs.nh.clean.enable;
assert nhEvaluation.config.programs.nh.clean.dates == "daily";
assert
  nixfmtFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.nixfmt nixfmtNixosEvaluation.config.environment.systemPackages;
assert builtins.elem pkgs.nixfmt nixfmtHomeEvaluation.config.home.packages;
assert
  devenvFeature.supportedEnvironments == [
    "integrated-home"
    "standalone-home"
  ];
assert builtins.elem pkgs.devenv devenvHomeEvaluation.config.home.packages;
pkgs.runCommand "qnix-system-check" { } "touch $out"
