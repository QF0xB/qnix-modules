{
  environments = [ "nixos" ];

  persistence.root.directories = [ "/etc/NetworkManager/system-connections" ];

  options =
    {
      isGraphical,
      lib,
      ...
    }:
    let
      pluginType = lib.types.oneOf [
        lib.types.package
        lib.types.str
      ];
    in
    {
      gui = lib.mkOption {
        type = lib.types.bool;
        default = isGraphical;
        description = "Whether to install and enable the NetworkManager tray applet.";
      };

      unmanaged = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Interfaces that NetworkManager should leave unmanaged.";
      };

      extraPlugins = lib.mkOption {
        type = lib.types.listOf pluginType;
        default = [ ];
        description = "Additional NetworkManager plugins to install.";
      };
    };

  nixos =
    {
      cfg,
      lib,
      options,
      pkgs,
      ...
    }:
    let
      resolvePlugin = plugin: if lib.isString plugin then pkgs.${plugin} else plugin;
      nmAppletOptionPath = [
        "programs"
        "nm-applet"
        "enable"
      ];
      nmAppletConfig =
        if lib.hasAttrByPath nmAppletOptionPath options then
          lib.setAttrByPath nmAppletOptionPath true
        else
          { environment.systemPackages = [ pkgs.networkmanagerapplet ]; };
    in
    lib.mkMerge [
      {
        networking = {
          useDHCP = lib.mkDefault false;
          networkmanager = {
            enable = true;
            unmanaged = cfg.unmanaged;
            plugins = map resolvePlugin cfg.extraPlugins;
          };
        };
      }
      (lib.mkIf cfg.gui nmAppletConfig)
    ];
}
