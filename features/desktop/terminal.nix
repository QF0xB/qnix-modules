{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  options =
    { lib, ... }:
    {
      server = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to keep the Foot server running for instant terminal launches.";
      };

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Additional Foot configuration settings.";
      };
    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    {
      programs.foot = {
        enable = true;
        server.enable = cfg.server;
        settings = cfg.settings;
      };

      home.sessionVariables.TERMINAL = if cfg.server then "footclient" else lib.getExe pkgs.foot;
    };
}
