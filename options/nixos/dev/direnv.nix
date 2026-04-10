{ lib, ... }:
{
  options.qnix.dev.direnv = {
    enable = lib.mkEnableOption "direnv";
  };
}
