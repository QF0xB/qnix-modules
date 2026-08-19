{
  features = [
    "system.localisation"
    "system.users"
    "shell.fish"
  ];

  defaults.system.users.defaultExtraGroups = [ "wheel" ];
  defaults.system.users.defaultShell = "fish";
}
