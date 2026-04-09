{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.browser = {
    enable = lib.mkEnableOption "browser" // {
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.brave;
      defaultText = lib.literalExpression "pkgs.brave";
      description = "Browser package used by desktop integrations.";
    };

    privateArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "--private-window" ];
      description = "Arguments used for the private browser keybind.";
    };
  };
}
