{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.autopairs.nvim-autopairs = {
      enable = true;
    };
  };
}
