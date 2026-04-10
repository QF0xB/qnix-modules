{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.screenshots = {
    enable = lib.mkEnableOption "Wayland screenshot tools" // {
      default = false;
    };

    grimPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.grim;
      defaultText = lib.literalExpression "pkgs.grim";
      description = "Package used to capture screenshots.";
    };

    slurpPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.slurp;
      defaultText = lib.literalExpression "pkgs.slurp";
      description = "Package used to select screenshot regions.";
    };

    annotationTool = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Optional screenshot annotation command exposed to desktop integrations.";
    };
  };
}
