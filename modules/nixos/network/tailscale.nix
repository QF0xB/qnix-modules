{
  lib,
  config,
  ...
}:
let
  cfg = config.qnix.network.tailscale;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.tailscale = {
      enable = true;
      package = cfg.package;
      openFirewall = cfg.openFirewall;
      extraUpFlags = cfg.extraUpFlags;
    };
  };
}
