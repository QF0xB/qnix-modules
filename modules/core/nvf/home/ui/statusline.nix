{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.statusline.lualine = {
      enable = true;
      disabledFiletypes = [
        "alpha"
      ];
    };
  };
}


