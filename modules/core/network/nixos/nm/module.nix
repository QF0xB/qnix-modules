{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.core.network.nm;
in
{
  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;

        unmanaged = cfg.unmanaged;

        # Map plugin names (strings) to packages in pkgs.
        plugins = builtins.map (p: pkgs.${p}) cfg.extraPlugins;
      };
    };

    environment.systemPackages = [
      pkgs.networkmanagerapplet
    ];

    qnix.persist.root.directories = [
      "/etc/NetworkManager/system-connections/"
    ];
  };
}
