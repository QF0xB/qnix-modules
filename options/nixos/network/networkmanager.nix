{ lib, ... }:
let
  pluginType = lib.types.oneOf [
    lib.types.package
    lib.types.str
  ];
in
{
  options.qnix.network.networkmanager = {
    enable = lib.mkEnableOption "NetworkManager";

    gui = lib.mkEnableOption "NetworkManager tray applet";

    unmanaged = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Interfaces that NetworkManager should leave unmanaged.";
    };

    extraPlugins = lib.mkOption {
      type = lib.types.listOf pluginType;
      default = [ ];
      description = "Extra NetworkManager plugins to install.";
    };
  };
}
