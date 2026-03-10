{ lib, ... }:

{
  options.qnix.core.virtualisation = {
    virt-manager = {
      enable = lib.mkEnableOption "virt-manager" // {
        default = false;
      };

      gui = lib.mkEnableOption "virt-manager gui" // {
        default = true;
      };

      passthrough = lib.mkEnableOption "passthrough" // {
        default = false;
      };
    };
  };
}
