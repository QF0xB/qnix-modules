{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.autopairs.nvim-autopairs = {
      enable = true;
    };
  };
}
