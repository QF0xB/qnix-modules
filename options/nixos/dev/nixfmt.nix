{ lib, ... }:
{
  options.qnix.dev.nixfmt = {
    enable = lib.mkEnableOption "nixfmt";
  };
}
