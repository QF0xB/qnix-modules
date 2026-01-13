{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.filetree.neo-tree = {
      enable = true;
    };
  };
}
