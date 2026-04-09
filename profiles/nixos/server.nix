{ lib, config, ... }:
{
  imports = lib.concatLists [
    (lib.qnix.mkNixosFeatureImports {
      category = "security";
      name = "fail2ban";
    })
    (lib.qnix.mkNixosFeatureImports {
      category = "security";
      name = "openssh";
    })
  ];

  config = {
      qnix = {
      status = {
        headless = lib.mkDefault true;
        server = lib.mkDefault true;
      };

      network.networkmanager = {
        enable = lib.mkDefault false;
        gui = lib.mkDefault false;
      };

      security = {
        fail2ban.enable = lib.mkDefault true;
        openssh.enable = lib.mkDefault true;
      };
    };
  };
}
