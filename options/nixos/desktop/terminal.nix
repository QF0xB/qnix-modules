{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.desktop.terminal = {
    enable = lib.mkEnableOption "terminal emulator";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kitty;
      defaultText = lib.literalExpression "pkgs.kitty";
      description = "Terminal emulator package to install and use by default.";
    };
  };
}
