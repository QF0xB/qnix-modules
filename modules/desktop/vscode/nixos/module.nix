{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.qnix.desktop.vscode.enable {
    qnix.persist.home.directories = [
      ".config/VSCodium"
      ".vscode-oss"
      ".config/Cursor"
    ];
  };
}
