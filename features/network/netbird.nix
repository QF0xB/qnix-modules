{
  environments = [ "nixos" ];

  # The peer key lives here; losing it registers the host as a new peer.
  persistence.root.directories = [ "/var/lib/netbird" ];

  options =
    { lib, ... }:
    {
      setupKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "File holding a NetBird setup key. When set, the host joins the network at boot without an interactive login.";
      };
    };

  nixos =
    { cfg, ... }:
    {
      services.netbird = {
        enable = true;
        clients.default.login = {
          enable = cfg.setupKeyFile != null;
          setupKeyFile = cfg.setupKeyFile;
        };
      };
    };
}
