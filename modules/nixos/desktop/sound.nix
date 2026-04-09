{
  lib,
  config,
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

    qnix.persist.users."*".directories = [
      ".local/state/wireplumber"
    ];
  };
}
