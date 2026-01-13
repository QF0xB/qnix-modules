{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.notify.nvim-notify = {
      enable = true;
    };
  };
}
