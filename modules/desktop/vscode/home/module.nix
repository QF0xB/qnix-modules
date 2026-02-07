{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.desktop.vscode;

  # Default to Cursor if no explicit package is set
  vscodePackage = cfg.package;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = vscodePackage;

      profiles.default = {
        userSettings = {
          "files.autoSave" = "onFocusChange";
          "keyboard.dispatch" = "keyCode";
          "redhat.telemetry.enabled" = "false";
          "qt-qml.qmlls.useQmlImportPathEnvVar" = "true";
        };
        extensions = with pkgs; [
          # Nix
          vscode-extensions.jnoortheen.nix-ide
          vscode-extensions.mkhl.direnv

          # Python
          vscode-extensions.ms-python.python

          # CPP
          vscode-extensions.ms-vscode.cpptools-extension-pack

          # VIM
          vscode-extensions.vscodevim.vim

          # Java
          vscode-extensions.vscjava.vscode-java-pack
          vscode-extensions.vscjava.vscode-spring-initializr
        ];
      };
    };
  };
}
