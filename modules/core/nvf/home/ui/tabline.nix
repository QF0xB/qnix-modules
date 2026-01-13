{ lib, osConfig, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    # SchroVimger-style tabline: thin separators, minimal indicators
    programs.nvf.settings.vim.tabline.nvimBufferline = {
      enable = true;
      setupOpts = {
        options = {
          show_buffer_close_icons = true;
          show_close_icon = false;
          show_filename_only = true;
          numbers = "none";
          modified_icon = "●";
          show_modified_icon = {
            __raw = ''
              function(buf)
                return buf.modified
              end
            '';
          };
          show_tab_indicators = false;
          separator_style = "thin";
          diagnostics = false;
          indicator = {
            style = "none";
          };
        };
      };
      mappings = {
        cycleNext = "<leader>bl";
        cyclePrevious = "<leader>bh";
        closeCurrent = "<leader>bx";
        pick = "<leader>bp";
        moveNext = "<leader>me";
        movePrevious = "<leader>mq";
      };
    };
  };
}
