{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.apps.notes = {
    enable = lib.mkEnableOption "notes application" // {
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.obsidian;
      defaultText = lib.literalExpression "pkgs.obsidian";
      description = "Notes application package used by desktop integrations.";
    };
  };
}
