{
  lib,
  pkgs,
  ...
}:

{
  options.qnix.dev.postman = {
    enable = lib.mkEnableOption "Postman";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postman;
      defaultText = lib.literalExpression "pkgs.postman";
      description = "Postman package wrapped for Wayland sessions.";
    };
  };
}
