{ lib, ... }:

{
  options.qnix.core.docker = {
    enable = lib.mkEnableOption "docker" // {
      default = false;
    };
  };
}
