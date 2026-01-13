{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim.formatter.conform-nvim = {
      enable = true;

      setupOpts = {
        defult_format_opts = {
          lsp_format = "fallback";
        };
        formatters_by_ft = {
          java = [ "google_java_format" ];
        };
      };
    };
  };
}
