{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.core.shell;
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
