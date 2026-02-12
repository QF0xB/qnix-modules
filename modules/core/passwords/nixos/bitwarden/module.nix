{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.core.passwords.bitwarden;
in
{
  config = {
    environment.systemPackages = lib.concatLists [
      (lib.optionals cfg.cli.enable [
        pkgs.bitwarden-cli
      ])
    ];

    qnix.persist.home.directories = lib.mkIf cfg.desktop.enable [
      ".config/Bitwarden"
    ];
  };
}
