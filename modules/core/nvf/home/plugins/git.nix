{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.git = {
      enable = true;

      neogit = {
        enable = true;
      };
    };
  };
}
