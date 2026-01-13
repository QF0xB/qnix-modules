{
  lib,
  config,
  ...
}:

let
  cfg = config.qnix.core.nvf;
in
{
  imports = [
    ./assistants
    ./core
    ./plugins
    ./ui
    ./utility
  ];

  config = {
    programs.nvf = lib.mkIf cfg.enable {
      enable = true;
      defaultEditor = true;
    };
  };
}
