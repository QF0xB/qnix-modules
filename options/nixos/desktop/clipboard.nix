{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.clipboard = {
    enable = lib.mkEnableOption "clipboard tools" // {
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.cliphist;
      defaultText = lib.literalExpression "pkgs.cliphist";
      description = "Clipboard history package used by desktop integrations.";
    };

    pickerPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fuzzel;
      defaultText = lib.literalExpression "pkgs.fuzzel";
      description = "Picker package used to select clipboard history entries.";
    };
  };
}
