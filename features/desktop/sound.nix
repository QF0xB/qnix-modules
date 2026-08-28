{
  environments = [
    "nixos"
    "integrated-home"
  ];

  persistence.users."*".directories = [
    ".local/state/wireplumber"
  ];

  options =
    {
      isGraphical,
      lib,
      ...
    }:
    {
      gui = lib.mkOption {
        type = lib.types.bool;
        default = isGraphical;
        description = "Whether to install graphical sound control applications.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      ...
    }:
    {
      security.rtkit.enable = lib.mkIf cfg.enable true;

      services.pipewire = {
        enable = lib.mkIf cfg.enable true;
        alsa.enable = lib.mkIf cfg.enable true;
        alsa.support32Bit = lib.mkIf cfg.enable true;
        pulse.enable = lib.mkIf cfg.enable true;
      };
    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = lib.mkIf cfg.enable (
        [
          pkgs.playerctl
        ]
        ++ lib.optionals cfg.gui [
          pkgs.easyeffects
          pkgs.pamixer
          pkgs.pavucontrol
        ]
      );
    };
}
