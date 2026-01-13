{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.notify.nvim-notify = {
      enable = true;
    };
  };
}
