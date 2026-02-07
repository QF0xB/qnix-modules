{
  lib,
  config ? null,
  ...
}:

{
  imports = [
    ./sddm-options.nix
  ];

  options.qnix.desktop.displaymanager = {
    enable = lib.mkEnableOption "displaymanager" // {
      default = config != null && !config.qnix.headless;
    };
  };
}
