{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.desktop.dev-utilities;
  enabled = cfg.enable || cfg.wireshark.enable;
in
{
  config = lib.mkIf enabled {
    programs.wireshark = {
      enable = true;
      dumpcap.enable = true;
      usbmon.enable = true;
    };

    # Add wireshark group to all users (via qnix user module)
    qnix.core.user.defaultExtraGroups = [ "wireshark" ];
  };
}
