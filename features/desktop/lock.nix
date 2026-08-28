{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires = {
    nixos = [ "desktop.wayland" ];
    home = [ "desktop.hyprland" ];
  };

  nixos =
    { ... }:
    {
      security.pam.services.hyprlock = { };
    };

  home =
    { ... }:
    {
      programs.hyprlock.enable = true;
    };
}
