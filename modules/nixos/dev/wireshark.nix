{ lib, config, ... }:
let
  cfg = config.qnix.dev.wireshark;
in
{
  config = lib.mkIf cfg.enable {
    programs.wireshark = {
      enable = true;
      dumpcap.enable = true;
      usbmon.enable = true;
    };

    qnix.system.users.defaultExtraGroups = [ "wireshark" ];
  };
}
