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

  options =
    { lib, pkgs, ... }:
    {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          signal-desktop
          element-desktop
        ];
        description = "Social application packages to install.";
      };
    };

  home =
    { cfg, ... }:
    {
      home.packages = cfg.packages;
    };
}
