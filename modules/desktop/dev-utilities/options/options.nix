{
  lib,
  config ? null,
  ...
}:

{
  options.qnix.desktop.dev-utilities = {
    enable = lib.mkEnableOption "dev-utilities" // {
      default = config != null && !config.qnix.headless && config.qnix.development;
    };

    postman.enable = lib.mkEnableOption "Postman development utility";

    wireshark.enable = lib.mkEnableOption "Wireshark development utility";
  };
}
