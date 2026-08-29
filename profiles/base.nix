{
  imports = [ "shell" ];

  features = [
    "system.boot"
    "system.localisation"
    "system.users"
    "network.addressing"
    "appearance.fonts"
    "storage.zfs"
  ];

  defaults.system.users.defaultExtraGroups = [ "wheel" ];
  defaults.system.users.defaultShell = "fish";
}
