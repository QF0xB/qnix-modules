{
  features = [
    "system.localisation"
    "system.users"
    "appearance.fonts"
    "shell.fish"
    "shell.zsh"
  ];

  defaults.system.users.defaultExtraGroups = [ "wheel" ];
  defaults.system.users.defaultShell = "fish";
}
