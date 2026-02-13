{
  lib,
  pkgs,
  ...
}:

{
  options.qnix.core.fingerprint = {
    enable = lib.mkEnableOption "fingerprint authentication (fprintd)" // {
      default = false;
    };

    login = lib.mkEnableOption "fingerprint for login (PAM)" // {
      default = false;
    };

    sudo = lib.mkEnableOption "fingerprint for sudo (PAM)" // {
      default = false;
    };

    tod = {
      enable = lib.mkEnableOption "Touch OEM Driver (for some laptop readers)" // {
        default = false;
      };
      driver = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        example = lib.literalExpression "pkgs.libfprint-2-tod1-goodix";
        description = "TOD driver package when tod.enable is true (e.g. libfprint-2-tod1-goodix, libfprint-2-tod1-elan).";
      };
    };
  };
}
