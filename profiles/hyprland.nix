{
  imports = [ "workstation" ];

  features = {
    nixos = [
      "apps.browser"
      "desktop.noctalia-greeter"
      "desktop.hyprland"
      "security.polkit"
      "security.gnome-keyring"
      "desktop.hyprland.monitors"
      "desktop.sound"
      "desktop.wayland"
      "system.plymouth"
    ];
    home = [
      "apps.browser"
      "apps.music"
      "apps.notes"
      "apps.obs"
      "apps.opencode"
      "apps.paseo"
      "apps.file-manager"
      "apps.social"
      "desktop.clipboard"
      "desktop.client-pr-notify"
      "desktop.hyprland"
      "desktop.hyprland.keybinds"
      "desktop.hyprland.monitors"
      "desktop.hyprland.rules"
      "desktop.hyprland.special-workspaces"
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

  defaults.desktop.client-pr-notify.enable = false;
}
