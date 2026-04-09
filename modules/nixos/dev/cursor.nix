{ lib, config, ... }:
let
  cfg = config.qnix.dev.cursor;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".config/VSCodium"
      ".vscode-oss"
      ".config/Cursor"
      ".cursor"
    ];
  };
}
