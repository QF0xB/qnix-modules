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

          # Cursor specific settings
          "cursor.composer.shouldChimeAfterChatFinishes" = true;
          "cursor.composer.usageSummaryDisplay" = "always";
          
          # Workbench panel settings (affects agent window size)
          "workbench.panel.defaultSize" = cfg.agentPanelSize;
          "workbench.sideBar.location" = "left";
          
          # Cursor agent panel settings
          "cursor.windowSwitcher.sidebarHoverCollapsed" = false;

          # Git settings for auto-refresh
          "git.autorefresh" = true;
          "git.autoRepositoryDetection" = true;
          "git.enabled" = true;
          "git.path" = null; # Use system git
          
          # File watching settings (helps with git status updates)
          "files.watcherExclude" = {
            "**/.git/objects/**" = true;
            "**/.git/subtree-cache/**" = true;
            "**/node_modules/**" = true;
          };
        };
        extensions = with pkgs; [
          # Nix
          vscode-extensions.jnoortheen.nix-ide
          vscode-extensions.mkhl.direnv

          # Python
          vscode-extensions.ms-python.python

          # CPP
          vscode-extensions.ms-vscode.cpptools-extension-pack

          # Java
          vscode-extensions.vscjava.vscode-java-pack
          vscode-extensions.vscjava.vscode-spring-initializr
        ];
      };
    };
  };
}
