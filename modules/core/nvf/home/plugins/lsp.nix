{ osConfig, lib, ... }:

{
  config = lib.mkIf osConfig.qnix.core.nvf.enable {
    programs.nvf.settings.vim = {
      lsp = {
        enable = true;
        lspconfig.enable = true;
        formatOnSave = true;
        lspSignature.enable = false;
        lspkind.enable = true;

        lspsaga = {
          enable = true;
          setupOpts = {
            lightbulb = {
              enable = false;
            };
          };
        };

        inlayHints = {
          enable = true;
        };
        lightbulb = {
          enable = false;
        };
      };

      ui.borders.plugins.lspsaga = {
        enable = true;
        style = "rounded";
      };
    };
  };
}
