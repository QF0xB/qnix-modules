{ lib, ... }:
{
  options.qnix.security.openssh = {
    enable = lib.mkEnableOption "openssh";

    ports = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ 22 ];
      description = "The ports on which to listen for SSH connections.";
    };
  };
}
