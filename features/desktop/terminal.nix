{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.foot;
        description = "Terminal package to install and use.";
      };

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
      ...
    }:
    {
      programs.foot = {
        enable = true;
        package = cfg.package;
        server.enable = cfg.server;
        settings = cfg.settings;
      };

      home.sessionVariables.TERMINAL = if cfg.server then "footclient" else lib.getExe cfg.package;
    };
}
