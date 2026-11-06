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
      autoLogin = {
        enable = lib.mkEnableOption "automatic Hyprland login followed by Noctalia session locking";
        user = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Existing normal user to log in automatically at boot.";
        };
      };

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
      pkgs,
      ...
    }:
    {
      assertions = lib.optional cfg.autoLogin.enable {
        assertion =
          cfg.autoLogin.user != ""
          && (config.users.users.${cfg.autoLogin.user}.isNormalUser or false)
          && config.programs.hyprland.enable
          && (lib.attrByPath [
            "home-manager"
            "users"
            cfg.autoLogin.user
            "programs"
            "noctalia"
            "systemd"
            "enable"
          ] false config)
          && (lib.attrByPath [
            "home-manager"
            "users"
            cfg.autoLogin.user
            "programs"
            "noctalia"
            "settings"
            "lockscreen"
            "enabled"
          ] false config);
        message = "Noctalia autologin requires an existing normal user with Hyprland and an autostarted Noctalia lockscreen in integrated Home Manager.";
      };

      services.greetd.settings.initial_session = lib.mkIf cfg.autoLogin.enable {
        user = cfg.autoLogin.user;
        command = "${lib.getExe pkgs.uwsm} start -S -F ${lib.getExe pkgs.hyprland}";
      };

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
