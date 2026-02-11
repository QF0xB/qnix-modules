{ config, lib, ... }:

let
  cfg = config.qnix.desktop.hyprdesktop;
in
{
  imports = [
    ./hyprsuite/module.nix
    ./noctalia/module.nix
  ];

  config = lib.mkIf cfg.enable {
    qnix.wayland = true;
  };
}
