{
  imports = [ "shell" ];

  features.nixos = [
    "system.boot"
    "system.localisation"
    "system.users"
    "network.addressing"
    "appearance.fonts"
    "storage.zfs"
  ];

  defaults.__qnixEnvironment.nixos.system.users = {
    defaultExtraGroups = [ "wheel" ];
    defaultShell = "fish";
  };
}
