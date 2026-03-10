{ lib, config, ... }:

{
  options.qnix.core.network.nm = {
    enable = lib.mkEnableOption "NetworkManager" // {
      default = true;
    };

    unmanaged = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of network interfaces to not manage with NetworkManager";
    };

    extraPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of extra NetworkManager plugins to install";
      example = [
        "nm-openvpn"
        "nm-openvpn-sniffer"
        "nm-openvpn-sniffer"
      ];
    };

    gui = lib.mkEnableOption "Networkmanager gui components" // {
      default = !config.qnix.headless;
    };
  };
}
