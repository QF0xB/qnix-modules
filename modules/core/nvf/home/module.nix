{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.core.nvf;
in
{
  imports = [
    ./assistants
    ./core
    ./plugins
    ./ui
    ./utility
  ];

  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      defaultEditor = true;
    };

    # Ensure ripgrep (rg) is available for NVF completion and search features
    home.packages = [ pkgs.ripgrep ];
  };
}
