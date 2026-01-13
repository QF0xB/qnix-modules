{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.spellcheck = {
      enable = true;

      languages = config.qnix.core.nvf.spellcheck.languages;

      vim-dirtytalk.enable = true;
      programmingWordlist.enable = true;

      extraSpellWords = config.qnix.core.nvf.spellcheck.additionalWords;
    };
  };
}
