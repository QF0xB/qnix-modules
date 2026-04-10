{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.apps.social = {
    enable = lib.mkEnableOption "social applications" // {
      default = false;
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.signal-desktop
        pkgs.element-desktop
      ];
      defaultText = lib.literalExpression "[ pkgs.signal-desktop pkgs.element-desktop ]";
      description = "Social and messenger application packages to install.";
    };

    persistDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        ".config/Signal"
        ".config/Element"
      ];
      description = "Directories relative to the home directory that should persist for social applications.";
    };
  };
}
