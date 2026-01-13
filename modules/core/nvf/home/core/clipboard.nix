{ lib, osConfig, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.clipboard = {
      enable = true;
      providers.wl-copy.enable = true;
      registers = "unnamedplus";
    };
  };
}
