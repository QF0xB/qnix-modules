{
  lib,
  config ? null,
  pkgs ? null,
  ...
}:

{
  options.qnix.desktop.vscode = {
    enable = lib.mkEnableOption "VS Code / Cursor" // {
      default = config != null && !config.qnix.headless;
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        VS Code package to install via the Home Manager vscode module
        (for example, pkgs.vscode, pkgs.vscodium or pkgs.cursor).
        If not set, the default package will be pkgs.cursor.
      '';
      default = if pkgs != null then pkgs.code-cursor else null;
    };

    agentPanelSize = lib.mkOption {
      type = lib.types.int;
      default = 400;
      description = "Default width (in pixels) for the Cursor agent panel/sidebar";
    };
  };
}
