{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.obs = {
    enable = lib.mkEnableOption "OBS Studio" // {
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.obs-studio;
      defaultText = lib.literalExpression "pkgs.obs-studio";
      description = "OBS Studio package used by desktop integrations.";
    };
  };
}
