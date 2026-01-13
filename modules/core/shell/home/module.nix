{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.core.shell;
in
{
  imports = [
    ./fish.nix
    ./aliases.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = (lib.attrValues cfg.packages);
  };
}
