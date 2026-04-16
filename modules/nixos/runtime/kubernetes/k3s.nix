{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.runtime.k3s;
in
{
  config = lib.mkIf cfg.enable {
    services.k3s = {
      enable = true;
      package = cfg.package;
      role = cfg.role;
      tokenFile = cfg.tokenFile;
      serverAddr = cfg.serverAddr;
      clusterInit = cfg.clusterInit;
      extraFlags = cfg.extraFlags;
    };
  };
}
