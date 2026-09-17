{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  options = { lib, ... }: {
    createDirectories = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to create the configured XDG user directories.";
    };

    setSessionVariables = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to export XDG user directory environment variables.";
    };
  };

  home = { cfg, ... }: {
    xdg.userDirs = {
      enable = cfg.enable;
      createDirectories = cfg.createDirectories;
      setSessionVariables = cfg.setSessionVariables;
    };
  };
}
