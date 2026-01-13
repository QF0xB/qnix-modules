{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.binds.whichKey = {
      enable = true;
      register = {
        "<leader>f" = "+files";
        "<leader>s" = "+splits/session";
        "<leader>m" = "+minimap/buffers";
        "<leader>b" = "+buffers";
        "<leader>g" = "+git";
      };

      setupOpts = {
        preset = "modern";
        notify = true;
        win = {
          border = "rounded";
        };
      };
    };
  };
}
