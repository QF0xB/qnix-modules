{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.hardtime.hardtime-nvim = {
      enable = true;

    };
  };
}
