{
  lib,
  config,
  options,
  pkgs,
  ...
}:
let
  cfg = config.qnix.network.networkmanager;

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
      {
        environment.systemPackages = [ pkgs.networkmanagerapplet ];
      };
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      networking = {
        useDHCP = lib.mkDefault false;
        networkmanager = {
          enable = true;
          unmanaged = cfg.unmanaged;
          plugins = map resolvePlugin cfg.extraPlugins;
        };
      };

      qnix.persist.root.directories = [
        "/etc/NetworkManager/system-connections"
      ];
    })

    (lib.mkIf (cfg.enable && cfg.gui) nmAppletConfig)

  ];
}
