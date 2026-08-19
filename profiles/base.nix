{
  features = [
    "system.localisation"
    "system.users"
    "shell.fish"
    "shell.zsh"
  ];

  defaults.system.users.defaultExtraGroups = [ "wheel" ];
  defaults.system.users.defaultShell = "fish";
}
