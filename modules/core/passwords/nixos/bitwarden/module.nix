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
  config = lib.mkIf cfg.cli.enable {
    environment.systemPackages = lib.concatLists [
      (lib.optionals cfg.cli.enable [
        pkgs.bitwarden-cli
      ])
    ];

    qnix.persist.home.directories = [
      ".config/Bitwarden"
    ];
  };
}
