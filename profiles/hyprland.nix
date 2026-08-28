{
  imports = [ "workstation" ];

  features = [
    "apps.browser"
    "apps.file-manager"
    "desktop.clipboard"
    "desktop.hyprland"
    "desktop.hyprland.keybinds"
    "desktop.hyprland.monitors"
    "desktop.hyprland.rules"
    "desktop.hyprland.special-workspaces"
    "desktop.displaymanager"
    "desktop.lock"
    "desktop.noctalia"
    "desktop.screenshots"
    "desktop.sound"
    "desktop.terminal"
    "desktop.xdg-folders"
  ];

  defaults.desktop.hyprland = {
    noHardwareCursors = true;
    devices = {
      "epic-mouse-v1".sensitivity = -0.5;
      "yubico-yubikey-otp+fido+ccid" = {
        kbLayout = "us";
        kbVariant = "";
        kbOptions = "";
      };
    };
  };
}
