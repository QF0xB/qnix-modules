{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.filetree.neo-tree = {
      enable = true;
    };
  }
}