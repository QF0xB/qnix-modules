{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.keymaps = [
      {
        key = "<leader>nn";
        mode = "n";
        silent = true;
        action = "<cmd>Neotree toggle<CR>";
        desc = "Toggle Neotree filesystem show";
      }
      {
        key = "<leader>ht";
        mode = "n";
        silent = true;
        action = "<cmd>Hardtime toggle<CR>";
        desc = "Toggle HardTime";
      }
    ];
  };
}
