{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.core.passwords.bitwarden;
in
{
  config = {
    home.packages = lib.concatLists [
      (lib.optionals cfg.desktop.enable [
        pkgs.bitwarden-desktop
      ])
    ];
  };
}
