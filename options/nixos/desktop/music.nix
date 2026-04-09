{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.music = {
    enable = lib.mkEnableOption "music application" // {
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.tidal-hifi;
      defaultText = lib.literalExpression "pkgs.tidal-hifi";
      description = "Music application package used by desktop integrations.";
    };
  };
}
