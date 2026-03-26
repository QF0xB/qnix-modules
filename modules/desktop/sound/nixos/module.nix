{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.desktop.sound;
in
{
  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = lib.mkIf cfg.gui.enable [
      pkgs.easyeffects
      pkgs.pavucontrol
      pkgs.pamixer
      pkgs.playerctl
    ];

    qnix.persist.home.directories = [
      ".local/state/wireplumber"
    ];
  };
}
