{
  environments = [ "nixos" ];

  requires.nixos = [
    "desktop.wayland"
    "system.localisation"
  ];

  persistence.root.directories = [ "/var/lib/noctalia-greeter" ];

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.noctalia-greeter;
        description = "Noctalia Greeter package to use.";
      };

      settings = lib.mkOption {
        type = (pkgs.formats.toml { }).type;
        default = { };
        description = "Overrides for Noctalia Greeter's upstream defaults, written to greeter.toml.";
      };
    };

  nixos =
    {
      cfg,
      config,
      lib,
      ...
    }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;
        package = cfg.package;
        settings = lib.mkMerge [
          {
            session.default = lib.mkDefault "Hyprland (uwsm-managed)";
            keyboard = {
              layout = lib.mkDefault config.services.xserver.xkb.layout;
              variant = lib.mkDefault config.services.xserver.xkb.variant;
              options = lib.mkDefault config.services.xserver.xkb.options;
            };
          }
          cfg.settings
        ];
      };
    };
}
