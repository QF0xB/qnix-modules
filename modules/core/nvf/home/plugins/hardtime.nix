{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.binds.hardtime-nvim = {
      enable = true;

    };
  };
}
