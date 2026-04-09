{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.lock = {
    enable = lib.mkEnableOption "screen lock application" // {
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hyprlock;
      defaultText = lib.literalExpression "pkgs.hyprlock";
      description = "Lock application package used by desktop integrations.";
    };
  };
}
