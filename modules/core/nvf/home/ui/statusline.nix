{ lib, osConfig, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.statusline.lualine = {
      enable = true;
      disabledFiletypes = [
        "alpha"
      ];
    };
  };
}
