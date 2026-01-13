{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.spellcheck = {
      enable = true;

      languages = osConfig.qnix.core.nvf.spellcheck.languages;

      vim-dirtytalk.enable = true;
      programmingWordlist.enable = true; # :DirtytalkUpdate

      extraSpellWords = {
        "en.utf-8" = osConfig.qnix.core.nvf.spellcheck.additionalWords;
      };
    };
  };
}
