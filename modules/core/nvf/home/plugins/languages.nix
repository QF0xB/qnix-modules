{ config, lib, ... }:

{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim.languages = {
      enableFormat = true;
      enableDAP = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      bash = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
      };

      clang = {
        enable = true;
        cHeader = true;
        dap.enable = true;
        lsp.enable = true;
      };

      html = {
        enable = true;
        treesitter.autotagHtml = true;
      };

      java = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };

      lua = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
      };

      nix = {
        enable = true;
        format.enable = true;
        format.type = "nixfmt";
        lsp.enable = true;
        lsp.server = "nixd";
        lsp.options = {
          nixpkgs = {
            expr = "import <nixpkgs> { }";
          };
        };
        extraDiagnostics.enable = true;
        extraDiagnostics.types = [
          "statix"
          "deadnix"
        ];
      };

      markdown = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        extensions.markview-nvim.enable = true;
        extensions.render-markdown-nvim.enable = true;
      };

      python = {
        enable = true;
        format.type = "black";
      };

      rust = {
        enable = true;
        crates.enable = true;
        crates.codeActions = true;
        format.enable = true;
        format.type = "rustfmt";
        lsp.enable = true;
      };

      sql = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
      };

      yaml = {
        enable = true;
        lsp.enable = true;
      };
    };
  };
}
