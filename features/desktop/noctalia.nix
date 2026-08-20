{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.hyprland" ];

  options =
    { lib, ... }:
    {
      autostart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Noctalia should start with the graphical session.";
      };
    };

  home =
    {
      cfg,
      ...
    }:
    {
      programs.noctalia-shell = {
        enable = true;
        systemd.enable = cfg.autostart;
      };
    };
}
