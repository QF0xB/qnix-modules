{ lib, ... }:

{
  options.qnix.dev.wireshark = {
    enable = lib.mkEnableOption "Wireshark";
  };
}
