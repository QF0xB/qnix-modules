{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.fileManager = {
    enable = lib.mkEnableOption "file manager" // {
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nemo;
      defaultText = lib.literalExpression "pkgs.nemo";
      description = "File manager package used by desktop integrations.";
    };
  };
}
