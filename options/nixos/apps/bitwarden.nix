{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.apps.bitwarden = {
    enable = lib.mkEnableOption "Bitwarden desktop" // {
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bitwarden-desktop;
      defaultText = lib.literalExpression "pkgs.bitwarden-desktop";
      description = "Bitwarden desktop package used by desktop integrations.";
    };
  };
}
