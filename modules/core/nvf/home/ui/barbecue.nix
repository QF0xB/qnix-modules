{
  osConfig,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim = {
      startPlugins = with pkgs.vimPlugins; [
        barbecue-nvim
        nvim-navic
        nvim-web-devicons
      ];

      pluginRC.barbecue-nvim = ''
        vim.opt.updatetime = 200

        require("barbecue").setup({
          attach_navic = true,
          theme = "auto",
          show_modified = true,
        })
      '';
    };
  };
}
