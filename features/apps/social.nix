{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [
    ".config/Signal"
    ".config/Element"
  ];

  home =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.signal-desktop
        pkgs.element-desktop
      ];
    };
}
