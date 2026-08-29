{
  imports = [
    "workstation"
    "developer"
  ];

  features = {
    nixos = [
      "desktop.displaymanager"
      "desktop.hyprland"
      "desktop.lock"
      "desktop.sound"
      "desktop.wayland"
    ];
    home = [
      "apps.browser"
      "apps.chatgpt"
      "apps.file-manager"
      "desktop.clipboard"
      "desktop.hyprland"
      "desktop.hyprland.keybinds"
      "desktop.hyprland.monitors"
      "desktop.hyprland.rules"
      "desktop.hyprland.special-workspaces"
      "desktop.lock"
      "desktop.noctalia"
      "desktop.screenshots"
      "desktop.terminal"
      "desktop.wayland"
      "desktop.xdg-folders"
    ];
  };

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
