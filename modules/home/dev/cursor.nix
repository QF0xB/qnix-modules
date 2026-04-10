{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  pkgs,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.dev.cursor or { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = cfg.package;

      profiles.default = {
        userSettings = {
          "files.autoSave" = "onFocusChange";
          "keyboard.dispatch" = "keyCode";
          "redhat.telemetry.enabled" = "false";
          "qt-qml.qmlls.useQmlImportPathEnvVar" = "true";

          "cursor.composer.shouldChimeAfterChatFinishes" = true;
          "cursor.composer.usageSummaryDisplay" = "always";
          "cursor.windowSwitcher.sidebarHoverCollapsed" = false;

          "workbench.panel.defaultSize" = cfg.agentPanelSize;
          "workbench.sideBar.location" = "left";

          "editor.formatOnPaste" = true;
          "editor.formatOnSave" = true;
          "editor.formatOnType" = true;
          "editor.formatOnSaveMode" = "file";

          "git.autorefresh" = true;
          "git.autoRepositoryDetection" = true;
          "git.enabled" = true;
          "git.path" = null;
          "git.showActionButton.publish" = false;
          "git.showActionButton.fetch" = false;
          "github.gitAuthentication" = false;
          "github.gitProtocol" = "ssh";

          "files.watcherExclude" = {
            "**/.git/objects/**" = true;
            "**/.git/subtree-cache/**" = true;
            "**/node_modules/**" = true;
          };

          "openapi.securityAuditToken" = "\${env:OPENAPI_SECURITY_AUDIT_TOKEN}";
        };

        extensions = with pkgs; [
          vscode-extensions.jnoortheen.nix-ide
          vscode-extensions.mkhl.direnv
          vscode-extensions."42crunch".vscode-openapi
          vscode-extensions.redhat.vscode-yaml
          vscode-extensions.ms-python.python
          vscode-extensions.ms-vscode.cpptools-extension-pack
          vscode-extensions.vscjava.vscode-java-pack
          vscode-extensions.vscjava.vscode-spring-initializr
        ];
      };
    };
  };
}
