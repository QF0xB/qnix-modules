{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.binds.hardtime-nvim = {
      enable = true;

    };
  };
}
