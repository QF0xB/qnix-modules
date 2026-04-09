{ lib, ... }:
{
  options.qnix.dev.devenv = {
    enable = lib.mkEnableOption "devenv";
  };
}
