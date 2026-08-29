{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".local/share/nvf" ];

  options =
    { lib, ... }:
    {
      spellcheck = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether NVF spellchecking is enabled.";
        };

        languages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "en"
            "de"
          ];
          description = "Spellchecking languages.";
        };

        additionalWords = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "nvf"
            "qnix"
            "qf0xb"
            "QPC"
            "QConfigVM"
            "QFrame13"
          ];
          description = "Additional spellchecking words.";
        };
      };
    };

  nixos =
    { ... }:
    { };

  home =
    { cfg, ... }:
    {
      programs.nvf = {
        enable = true;
        defaultEditor = true;

        settings.vim = {
          autocomplete.blink-cmp.enable = true;
          autopairs.nvim-autopairs.enable = true;

          clipboard = {
            enable = true;
            providers.wl-copy.enable = true;
            registers = "unnamedplus";
          };

          options = {
            number = true;
            relativenumber = true;
            tabstop = 2;
            softtabstop = 2;
            shiftwidth = 2;
            expandtab = true;
            autoindent = true;
            smartindent = true;
            breakindent = true;
            foldcolumn = "1";
            foldlevel = 99;
            foldlevelstart = 99;
            foldenable = false;
            wrap = false;
          };

          filetree.neo-tree.enable = true;
          git = {
            enable = true;
            neogit.enable = true;
          };

          languages = {
            enableFormat = true;
            enableTreesitter = true;
            bash = {
              enable = true;
              format.enable = true;
              lsp.enable = true;
            };
            lua = {
              enable = true;
              format.enable = true;
              lsp.enable = true;
            };
            markdown = {
              enable = true;
              format.enable = true;
              lsp.enable = true;
              extensions.render-markdown-nvim.enable = true;
            };
            nix = {
              enable = true;
              format.enable = true;
              lsp.enable = true;
              lsp.servers = [ "nixd" ];
              extraDiagnostics = {
                enable = true;
                types = [
                  "statix"
                  "deadnix"
                ];
              };
            };
            python = {
              enable = true;
              format.enable = true;
              lsp.enable = true;
            };
            rust = {
              enable = true;
              format.enable = true;
              lsp.enable = true;
            };
            yaml = {
              enable = true;
              lsp.enable = true;
            };
          };

          lsp = {
            enable = true;
            lspconfig.enable = true;
            formatOnSave = true;
            lspkind.enable = true;
            inlayHints.enable = true;
          };

          spellcheck = {
            enable = cfg.spellcheck.enable;
            languages = cfg.spellcheck.languages;
            extraSpellWords."en.utf-8" = cfg.spellcheck.additionalWords;
          };

          treesitter = {
            enable = true;
            fold = true;
            highlight.enable = true;
            indent.enable = true;
            addDefaultGrammars = true;
          };
        };
      };
    };
}
