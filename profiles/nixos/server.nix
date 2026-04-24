{ lib, config, ... }:
let
  sharedQnix = import ../shared/server.nix { inherit lib; };
in
{
  imports = [ ./base.nix ] ++ lib.concatLists [
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
    qnix = lib.recursiveUpdate sharedQnix {
      network.networkmanager = {
        enable = lib.mkDefault false;
        gui = lib.mkDefault false;
      };

      security = {
        fail2ban.enable = lib.mkDefault true;
        openssh.enable = lib.mkDefault true;
      };

      # Default server role targets VMs/containers unless a host opts into ZFS explicitly.
      storage.zfs.enable = lib.mkForce false;
    };
  };
}
