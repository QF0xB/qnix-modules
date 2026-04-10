{
  lib,
  pkgs,
  ...
}:

{
  options.qnix.dev.codex = {
    enable = lib.mkEnableOption "Codex CLI";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.codex;
      defaultText = lib.literalExpression "pkgs.codex";
      description = "Codex CLI package to install for development workflows.";
    };
  };
}
