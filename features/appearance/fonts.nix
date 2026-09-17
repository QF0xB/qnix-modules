{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  options =
    {
      lib,
      pkgs,
      ...
    }:
    {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ pkgs.nerd-fonts.jetbrains-mono ];
        description = "Fonts installed for the system or Home Manager user.";
      };
    };

  nixos =
    { cfg, ... }:
    {
      fonts.packages = cfg.packages;
    };

  home =
    { cfg, ... }:
    {
      home.packages = cfg.packages;
    };
}
