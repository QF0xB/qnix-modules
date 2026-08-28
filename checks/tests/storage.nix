{ ctx }:
with ctx;
assert zfsFeature.supportedEnvironments == [ "nixos" ];
assert
  zfsImpermanenceEvaluation.config.boot.initrd.systemd.services.qnix-impermanence-reset.before
  == [ "sysroot.mount" ];
assert
  zfsImpermanenceEvaluation.config.boot.initrd.systemd.services.qnix-impermanence-reset.after == [
    "zfs-import.target"
    "systemd-cryptsetup@cryptroot.service"
  ];
assert
  builtins.match ".*zfs rollback -r zroot/root@blank.*" zfsImpermanenceEvaluation.config.boot.initrd.systemd.services.qnix-impermanence-reset.script
  != null;
assert persistEvaluation.config.qnix.persist.root.directories == [ ];
assert persistEvaluation.config.qnix.persist.users == { };
assert persistConfiguredEvaluation.config.qnix.persist.root.directories == [ "/var/lib/example" ];
assert persistConfiguredEvaluation.config.qnix.persist.root.files == [ "/etc/example.conf" ];
assert
  persistConfiguredEvaluation.config.qnix.persist.root.cache.directories == [ "/var/cache/example" ];
assert
  persistConfiguredEvaluation.config.qnix.persist.root.cache.files == [ "/var/cache/example.state" ];
assert
  persistConfiguredEvaluation.config.qnix.persist.users.tester.directories
  == [ ".local/share/example" ];
assert
  persistConfiguredEvaluation.config.qnix.persist.users.tester.files == [ ".config/example.conf" ];
assert
  persistConfiguredEvaluation.config.qnix.persist.users.tester.cache.directories
  == [ ".cache/example" ];
assert
  persistConfiguredEvaluation.config.qnix.persist.users.tester.cache.files
  == [ ".cache/example.state" ];
assert !invalidPersistPath.success;
assert
  impermanenceFeature.supportedEnvironments == [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];
assert impermanenceEvaluation.config.fileSystems."/persist".neededForBoot;
assert impermanenceEvaluation.config.fileSystems."/cache".neededForBoot;
assert impermanenceEvaluation.config.services.journald.storage == "persistent";
assert
  directoryPaths impermanenceEvaluation.config.environment.persistence."/persist".directories == [
    "/var/lib/nixos"
    "/var/lib/example"
  ];
assert
  directoryPaths impermanenceEvaluation.config.environment.persistence."/cache".directories == [
    "/var/log"
    "/var/log/journal"
    "/var/cache/example"
  ];
assert impermanenceEvaluation.config.environment.persistence."/persist".allowTrash;
assert impermanenceEvaluation.config.environment.persistence."/cache".allowTrash;
assert
  filePaths impermanenceEvaluation.config.environment.persistence."/persist".files
  == [ "/etc/example.conf" ];
assert
  filePaths impermanenceEvaluation.config.environment.persistence."/cache".files
  == [ "/var/cache/example.state" ];
assert
  directoryPaths
    impermanenceEvaluation.config.environment.persistence."/persist".users.tester.directories == [
    "Projects"
    ".ssh"
    ".local/share/example"
  ];
assert
  filePaths impermanenceEvaluation.config.environment.persistence."/persist".users.tester.files
  == [ ".config/example.conf" ];
assert
  directoryPaths
    impermanenceEvaluation.config.environment.persistence."/cache".users.tester.directories == [
    ".cache"
    ".gradle"
    ".cache/example"
  ];
assert
  filePaths impermanenceEvaluation.config.environment.persistence."/cache".users.tester.files == [
    ".cache/example.state"
    ".cache/tester.state"
  ];
assert
  directoryPaths
    impermanenceEvaluation.config.environment.persistence."/persist".users.alice.directories == [
    "Projects"
    ".ssh"
    ".local/share/example"
    "alice-data"
  ];
assert
  directoryPaths
    impermanenceEvaluation.config.environment.persistence."/cache".users.alice.directories == [
    ".cache"
    ".gradle"
    ".cache/example"
  ];
assert impermanenceEvaluation.config.environment.etc."impermanence.json".source != null;
assert builtins.elem "/var/lib/nixos" impermanenceManifest.directories;
assert builtins.elem "/etc/example.conf" impermanenceManifest.files;
assert builtins.elem "/home/tester/.local/share/example" impermanenceManifest.directories;
assert builtins.elem "/home/tester/.cache/tester.state" impermanenceManifest.files;
assert builtins.elem "/home/alice/alice-data" impermanenceManifest.directories;
pkgs.runCommand "qnix-storage-check" { } "touch $out"
