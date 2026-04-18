{ lib, pkgs, ... }:
let
  hasNixosBlur = pkgs ? qnix-pkgs && pkgs.qnix-pkgs ? nixos-blur;
in
{
  options.qnix.system.plymouth = {
    enable = lib.mkEnableOption "Plymouth boot splash";

    theme = lib.mkOption {
      type = lib.types.str;
      default = if hasNixosBlur then "nixos-blur" else "nixos-bgrt";
      defaultText = lib.literalExpression ''if pkgs.qnix-pkgs.nixos-blur is available then "nixos-blur" else "nixos-bgrt"'';
      description = "Plymouth theme name. Defaults to the old qnix nixos-blur theme when available.";
    };

    themePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.qnix-pkgs.nixos-blur or pkgs.nixos-bgrt-plymouth;
      defaultText = lib.literalExpression "pkgs.qnix-pkgs.nixos-blur or pkgs.nixos-bgrt-plymouth";
      description = "Package providing the configured Plymouth theme.";
    };

    quietBoot = lib.mkEnableOption "quiet boot kernel and initrd output" // {
      default = true;
    };
  };
}
