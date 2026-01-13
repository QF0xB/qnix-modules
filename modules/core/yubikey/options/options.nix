{
  lib,
  config ? null,
  isLaptop ? false,
  ...
}:

{
  options.qnix.core.yubikey = {
    enable = lib.mkEnableOption "yubikey integration" // {
      default = true;
    };

    gui = lib.mkEnableOption "yubikey management guis" // {
      default = !(if (config != null) then config.qnix.headless else false);
    };

    login = lib.mkEnableOption "login with yubikey" // {
      default = false;
    };

    sudo = lib.mkEnableOption "sudo with yubikey" // {
      default = true;
    };

    autolock = lib.mkEnableOption "autolock on yubikey removal" // {
      default = isLaptop;
    };
  };
}
