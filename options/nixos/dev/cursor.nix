{
  lib,
  pkgs,
  ...
}:

{
  options.qnix.dev.cursor = {
    enable = lib.mkEnableOption "Cursor editor";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.code-cursor;
      defaultText = lib.literalExpression "pkgs.code-cursor";
      description = "Cursor-compatible VS Code package installed via Home Manager.";
    };

    agentPanelSize = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Default width in pixels for the Cursor agent panel.";
    };
  };
}
