{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.git = {
      enable = true;

      neogit = {
        enable = true;
      };
    };
  };
}
